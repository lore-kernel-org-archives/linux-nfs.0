From: Douglas Furlong <douglas.furlong@firebox.com>
Subject: Re: NFS server not responding
Date: Thu, 27 Nov 2003 19:07:13 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069960032.4680.71.camel@wibbit.firebox.com>
References: <1069934421.4677.77.camel@wibbit.firebox.com>
	 <shsfzg93hag.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APRU3-000546-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 11:07:23 -0800
Received: from dsl-217-155-91-196.zen.co.uk ([217.155.91.196] helo=helium.firebox.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1APRU2-0004yy-S7
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 11:07:23 -0800
Received: from localhost (helium.firebox.com [127.0.0.1])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hARJ019e026753
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 19:00:01 GMT
Received: from helium.firebox.com ([127.0.0.1])
 by localhost (helium.firebox.com [127.0.0.1]) (amavisd-new, port 10024)
 with LMTP id 26480-03-3 for <nfs@lists.sourceforge.net>;
 Thu, 27 Nov 2003 19:00:01 +0000 (GMT)
Received: from [192.168.0.150] (wibbit.firebox.com [192.168.0.150])
	by helium.firebox.com (8.12.8/8.12.8) with ESMTP id hARIxvUh026722
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 18:59:57 GMT
To: nfs@lists.sourceforge.net
In-Reply-To: <shsfzg93hag.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2003-11-27 at 16:30, Trond Myklebust wrote:
> >>>>> " " == Douglas Furlong <douglas.furlong@firebox.com> writes:
> 
>      > Good day all.  I am running in to excessive amounts of NFS
>      > errors as below.
> 
>      > kernel: nfs: server neon not responding, still trying kernel:
>      > nfs: server neon OK
> 
> Two suggestions:
> 
>  1) Bump the number of threads on the server. 32 is probably a bit
>     low.

I have upped this to 64 now. Is there a rule of thumb with regards to
the number of people connecting/amount of system resources?

>  2) The value retrans=3 used as the default by the Linux 'mount'
>     program is rather low compared to that used on other OSes. I
>     suggest you bump it to at least 5 on all your clients.

I have increased the retrans value to 10 now. This appears to have
resolved the problems to a greater extent.

What sort of things would be causing the client to have to re-transmit
so often?

Client rpc stats:
calls      retrans    authrefrsh
3431978    15968      0    

Those retrans numbers, as a percentage of the calls, does it seem
appropriate?

Thanks for the tips.

Doug



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
