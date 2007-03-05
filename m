From: Neil Brown <neilb@suse.de>
Subject: Re: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Mon, 5 Mar 2007 14:07:53 +1100
Message-ID: <17899.35209.373099.331797@notabene.brown>
References: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
	<17899.31457.535979.478100@notabene.brown>
	<a6a251db0703041812h7bd3e771q690e30cc789189e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Matt Proud" <matt.proud.list@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO3ZY-0007vy-AA
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 19:09:12 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HO3ZY-00080K-S0
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 19:09:14 -0800
In-Reply-To: message from Matt Proud on Sunday March 4
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sunday March 4, matt.proud.list@gmail.com wrote:
> I'll give those new nfs-utils a try tomorrow.

No need thanks, I can duplicate the problem with current nfs-utils.

> rpc.mount 21766 root   32u  IPv4           12956690                TCP
> mail.xxx.xxx.xxx:764->calvin.xxx.xxx.xxx:684 (CLOSE_WAIT)
> rpc.mount 21766 root   33u  IPv4           12956694                TCP
> mail.xxx.xxx.xxx:764->cyan.xxx.xxx.xxx:709 (CLOSE_WAIT)
> rpc.mount 21766 root   34u  IPv4           12956695                TCP
> mail.xxx.xxx.xxx:764->denim.xxx.xxx.xxx:763 (CLOSE_WAIT)
> rpc.mount 21766 root   35u  sock                0,5           12956696
> can't identify protocol
> rpc.mount 21766 root   36u  IPv4           12956697                TCP
> mail.xxx.xxx.xxx:764->peach.xxx.xxx.xxx:930 (CLOSE_WAIT)
> rpc.mount 21766 root   37u  IPv4           12956698                TCP
> mail.xxx.xxx.xxx:764->orange.xxx.xxx.xxx:693 (CLOSE_WAIT)
> rpc.mount 21766 root   38u  IPv4           12956699                TCP
> mail.xxx.xxx.xxx:764->app64.xxx.xxx.xxx:1007 (CLOSE_WAIT)
> rpc.mount 21766 root   39u  IPv4           12956701                TCP
> mail.xxx.xxx.xxx:764->black.xxx.xxx.xxx:767 (CLOSE_WAIT)
> rpc.mount 21766 root   40u  IPv4           12956710                TCP
> mail.xxx.xxx.xxx:764->green.xxx.xxx.xxx:887 (CLOSE_WAIT)
> 

They are all in 'CLOSE_WAIT' meaning that the client has closed it's
end of the connection and mountd should close it's end.

The fact that they are all > 32 is suspicious.  fds less than that are
getting closed, these aren't.

In fact, if I try to make lots of connections to mountd, it goes into
a spin as soon as anything happens on an fd >= 32, whether a read or a
close.

It looks like a glibc bug.
Looking at glibc-2.3.6 (which I happen to have lying around), in
sunrpc/svc.c we have

void
svc_getreqset (fd_set *readfds)
{
  register fd_mask mask;
  register fd_mask *maskp;
  register int setsize;
  register int sock;
  register int bit;

  setsize = _rpc_dtablesize ();
  if (setsize > FD_SETSIZE)
    setsize = FD_SETSIZE;
  maskp = readfds->fds_bits;
  for (sock = 0; sock < setsize; sock += NFDBITS)
    for (mask = *maskp++; (bit = ffs (mask)); mask ^= (1 << (bit - 1)))
      INTUSE(svc_getreq_common) (sock + bit - 1);
}

'fd_mask' is defined in sys/select.h to be 'long int', so we shouldn't
be calling 'ffs', we should be calling 'ffsl'.
Also, the
          mask ^= (1 << (bit - 1))
should be
          mask ^= (1L << (bit - 1))

If I make those two changes, stick that code in svc_run.c, rename it
to my_svc_getreqset and call that function instead of svc_getreqset,
it works fine.

Ho hum.  Time to set a bug report off to glibc...


For now:  Well, you could try finding a 32bit mountd and run that.  Or
make the same change I did and compile something yourself.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
