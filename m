From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: how to check if file locking is working?
Date: Thu, 03 May 2007 15:36:55 +0200
Message-ID: <4639E577.6090201@wpkg.org>
References: <46308D00.5040109@wpkg.org> <463098C8.8010900@wpkg.org>	
	<1177882063.6400.39.camel@heimdal.trondhjem.org>	
	<4636DD23.2000509@wpkg.org>
	<1178002901.5588.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hjbke-0006Fq-59
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 06:53:44 -0700
Received: from mail.syneticon.net ([213.239.212.131] helo=mail2.syneticon.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hjbke-0003lb-IZ
	for nfs@lists.sourceforge.net; Thu, 03 May 2007 06:53:46 -0700
In-Reply-To: <1178002901.5588.11.camel@heimdal.trondhjem.org>
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

Trond Myklebust schrieb:

>>>> Kernel option on a client or server, export options on the server, mount 
>>>> options on the client etc.?
>>> nfsroot does not support NFSv4 at this time.
>> Hmm, I didn't say anything about nfsroot, did I?
>>
>> I merely did a chroot over NFSv4, and some apps don't work well then.
> 
> Sorry. I misread your mail. The easiest way to check basic locking would
> be to run the connectathon suite. See
> http://www.connectathon.org/#technologies

It looks like it's not working when I mount an export as NVSv4.
What can be wrong?


-- 
Tomasz Chmielewski
http://wpkg.org

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
