From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: maybe a svcsock.c/sv_lock deadlock?
Date: Tue, 27 Jul 2004 19:43:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407271943.47867.bernd-schubert@web.de>
References: <20040727141433.GB11023@suse.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_TRpBB0311aVLEg3"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpVzb-0001Wd-LW
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 10:43:59 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpVza-0006ar-Rp
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 10:43:59 -0700
Received: from [80.140.9.18] (helo=bathl.lan.fli4l)
	by smtp06.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.101 #44)
	id 1BpVzR-00067g-00
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 19:43:50 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20040727141433.GB11023@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Boundary-00=_TRpBB0311aVLEg3
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello Olaf,

> I have a somewhat unclear bug report against the 2.6 kernel, where
> the sysrq output seems to indicate there's a deadlock on sv_lock
> somewhere. There is a stuck process is in tcp_data_ready, but
> unfortunately the sysrq output is not complete, so I don't know what
> the other CPUs were doing at the time.
>
> Looking at the code, I did notice however that some new code was
> added recently (svc_defer, svc_revisit) that uses spin_lock instead of
> spin_lock_bh when grabbing the sv_lock.
>
> So it seems there's potential for deadlock if TCP data arrives while
> one of these new functions hold sv_lock.
>
> Comments?

When we tried to use 2.6.7 it happend two time that the machine was working 
but the clients simply could not reach the nfs-server. 
We didn't have much time to care about it and simply rebooted the server, 
however, before doing that we issued sysrq+t. 
I've attached the full trace, maybe its related to your trace?

Cheers,
	Bernd


PS: Unfortunality I can't read those traces, oopses, etc., is there any 
documentation how to read it?

--Boundary-00=_TRpBB0311aVLEg3
Content-Type: application/x-gzip;
  name="trace.log.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="trace.log.gz"

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
//udwfhf0e25aAiEAAA=

--Boundary-00=_TRpBB0311aVLEg3--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
