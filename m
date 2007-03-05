From: "Matt Proud" <matt.proud.list@gmail.com>
Subject: Re: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Sun, 4 Mar 2007 20:12:25 -0600
Message-ID: <a6a251db0703041812h7bd3e771q690e30cc789189e0@mail.gmail.com>
References: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
	<17899.31457.535979.478100@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO2gd-0002hX-08
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 18:12:27 -0800
Received: from wr-out-0506.google.com ([64.233.184.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HO2gd-0008Jm-NK
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 18:12:29 -0800
Received: by wr-out-0506.google.com with SMTP id i30so1237495wra
	for <nfs@lists.sourceforge.net>; Sun, 04 Mar 2007 18:12:26 -0800 (PST)
In-Reply-To: <17899.31457.535979.478100@notabene.brown>
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

I'll give those new nfs-utils a try tomorrow.

Here's what lsof says:

root@mail:~# lsof -p 21766
COMMAND     PID USER   FD   TYPE             DEVICE    SIZE       NODE NAME
rpc.mount 21766 root  cwd    DIR              253,4      91   25168840
/var/lib/nfs
rpc.mount 21766 root  rtd    DIR              253,0    4096          2 /
rpc.mount 21766 root  txt    REG              253,2   75272   16777397
/usr/sbin/rpc.mountd
rpc.mount 21766 root  mem    REG                0,0                  0
[heap] (stat: No such file or directory)
rpc.mount 21766 root  mem    REG              253,0   96096     262157
/lib/ld-2.3.6.so
rpc.mount 21766 root  mem    REG              253,0 1272336     262202
/lib/libc-2.3.6.so
rpc.mount 21766 root  mem    REG              253,0   85984     262281
/lib/libnsl-2.3.6.so
rpc.mount 21766 root  mem    REG              253,0   35968     262613
/lib/libwrap.so.0.7.6
rpc.mount 21766 root  mem    REG              253,0   44056     262301
/lib/libnss_files-2.3.6.so
rpc.mount 21766 root  mem    REG              253,0   39928     262357
/lib/libnss_nis-2.3.6.so
rpc.mount 21766 root  mem    REG              253,4  217016   25169923
/var/db/nscd/hosts
rpc.mount 21766 root    0u   CHR                1,3               6187 /dev/null
rpc.mount 21766 root    1u   CHR                1,3               6187 /dev/null
rpc.mount 21766 root    2u   CHR                1,3               6187 /dev/null
rpc.mount 21766 root    3u   REG                0,3       0 4026532520
/proc/net/rpc/auth.unix.ip/channel
rpc.mount 21766 root    4u   REG                0,3       0 4026532570
/proc/net/rpc/nfsd.export/channel
rpc.mount 21766 root    5u   REG                0,3       0 4026532574
/proc/net/rpc/nfsd.fh/channel
rpc.mount 21766 root    6u  IPv4           12238621                UDP
*:passwd_server
rpc.mount 21766 root    7u  IPv4           12238636                TCP
*:764 (LISTEN)
rpc.mount 21766 root    9u  unix 0xffff81005777ae40           12242159 socket
rpc.mount 21766 root   32u  IPv4           12956690                TCP
mail.xxx.xxx.xxx:764->calvin.xxx.xxx.xxx:684 (CLOSE_WAIT)
rpc.mount 21766 root   33u  IPv4           12956694                TCP
mail.xxx.xxx.xxx:764->cyan.xxx.xxx.xxx:709 (CLOSE_WAIT)
rpc.mount 21766 root   34u  IPv4           12956695                TCP
mail.xxx.xxx.xxx:764->denim.xxx.xxx.xxx:763 (CLOSE_WAIT)
rpc.mount 21766 root   35u  sock                0,5           12956696
can't identify protocol
rpc.mount 21766 root   36u  IPv4           12956697                TCP
mail.xxx.xxx.xxx:764->peach.xxx.xxx.xxx:930 (CLOSE_WAIT)
rpc.mount 21766 root   37u  IPv4           12956698                TCP
mail.xxx.xxx.xxx:764->orange.xxx.xxx.xxx:693 (CLOSE_WAIT)
rpc.mount 21766 root   38u  IPv4           12956699                TCP
mail.xxx.xxx.xxx:764->app64.xxx.xxx.xxx:1007 (CLOSE_WAIT)
rpc.mount 21766 root   39u  IPv4           12956701                TCP
mail.xxx.xxx.xxx:764->black.xxx.xxx.xxx:767 (CLOSE_WAIT)
rpc.mount 21766 root   40u  IPv4           12956710                TCP
mail.xxx.xxx.xxx:764->green.xxx.xxx.xxx:887 (CLOSE_WAIT)


On 3/4/07, Neil Brown <neilb@suse.de> wrote:
> On Sunday March 4, matt.proud.list@gmail.com wrote:
> >
> > When rpc.mountd acts funny, an attached strace reveals the a select
> > function call occurring very rapidly:
> >
> > select(1024, [3 4 5 6 7 32 33 34 35 36 37 38 39 40], NULL, NULL, NULL)
> > = 9 (in [32 33 34 35 36 37 38 39 40])
>
> It would help if we could see matching "lsof -p xxx" output to see
> exactly what those 9 fds are, but they are presumably tcp connections.
>
> I cannot imagine why mountd would spin on something like that - if
> select says that it can read from those fds, it should try to read...
>
> It might be worth trying a newer nfs-utils.  Just grab
> 1.0.12 from
>    http://www.kernel.org/pub/linux/utils/nfs/
>
> ./configure --without-nfsv4 --without-gss
> make
>
> then kill mountd and run ./utils/mountd/mountd
>
> See if that makes a difference.
>
> NeilBrown
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
