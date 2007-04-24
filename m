From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 11:10:23 -0400
Message-ID: <462E1DDF.5060203@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: =?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_?=@sc8-sf-spam2.sourceforge.net,
	Neil Brown <neilb@suse.de>, Matthias Koenig <mkoenig@novell.com>,
	nfs@lists.sourceforge.net,
	=?ISO-8859-1?Q?Pe=F1a?= <jfs@computer.org>,
	Tony Reix <tony.reix@bull.net>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@Oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgMfB-0004zm-Oa
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:10:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgMfD-0001oz-09
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 08:10:44 -0700
In-Reply-To: <200704240908.39672.olaf.kirch@oracle.com>
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

Olaf Kirch wrote:
> On Tuesday 24 April 2007 01:09, Neil Brown wrote:
>> Is there someone "maintaining" rpcbind?  Should there be?
>> I notice there is an rpcbind at Wietse Venema's site:
>>   ftp://ftp.porcupine.org/pub/security/index.html
>>
>> Is this rpcbind derived from that?
> 
> Bull maintains a copy of rpcbind alongside their tirpc code.
> I think both Wietse's and Bull's rpcbind implementation derive
> from the TI-RPC code released by Sun some time during the
> last millenium.
> 
> Personally, I'm very wary of the tirpc code. I think it needs a haircut
> and a thorough security audit before it can go into distributions.
I agree the code is a bit rough at this point... and care should be
taken with who and how the code is used at this point, which is
the reason only rpcbind is using the library and rpcbind is not
running  as root... but... I do think correct way to go in
the supporting of IPv6 and other well established features.


> I did a very quick comparison of the tirpc code vs glibc, and
> I think there's a potential buffer overflow if a rogue rpcbind server
> replies with a string length of 0xffffffff.
> 
> The rpcb_clnt.c functions use xdr_wrapstring, which
> gives a max string size of MAX_UNSIGNED, so a string
> length of 0xffffffff would be acceptable. The subsequent malloc
> would allocate a buffer of length 0 however. Depending on
> how you link your binary, malloc may return NULL in that case
> (simple segfault), or a very small buffer - and the moment you
> start copying to that, you will corrupt the heap. This is fixed
> in glibc, but still exists in tirpc. A security audit may turn up
> more.
Yes... there is a ton of wisdom we can pull from the glibc code
to make this code better... and since the glibc people are for
this movement (i.e. moving away from the glibc RPC code) I'm
hoping they will be willing to help us out in this effort...

> 
> Apart from these concerns, the coding style is abominable - K&R
> almost everywhere; there's still a bunch of u_long's in 
> the code which makes it non-64bit-clean, and there's
> crap like
> 
> clnt_st = CLNT_CALL(client, (rpcproc_t)RPCBPROC_GETADDR,
>                     (xdrproc_t) xdr_rpcb, (char *)(void *)&parms,
>                     (xdrproc_t) xdr_wrapstring, (char *)(void *) &ua, *tp);
> 
> Those casts aren't just plain ugly, they're utterly useless too, since
> the pointer arguments to cl_call are void *.
Yes the coding style a bit challenging.... but again this is something
that is definitely fixable over time...

Are there any tools out there that might help with the cleaning up
of this code?


steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
