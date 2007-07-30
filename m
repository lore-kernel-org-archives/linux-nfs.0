From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Mon, 30 Jul 2007 00:14:28 -0400
Message-ID: <46AD65A4.5040403@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>
	<46AA4989.8040003@oracle.com> <46AB4290.4090408@RedHat.com>
	<46ABAE5F.1000208@oracle.com> <46ACE951.60806@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030701050208010504000505"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFMfn-0002PY-9w
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 21:15:59 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFMfp-0001VM-RL
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 21:16:03 -0700
In-Reply-To: <46ACE951.60806@RedHat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------030701050208010504000505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
>>>> I can't see why we need to refer back to either file to determine 
>>>> the transport protocol for a umount request.  Whatever transport 
>>>> mountd is advertising at the moment is what should be used, right?
>>> Well for firewall reasons you generally want to use the protocol
>>> that the mount used...
>>
>> That could have been a very long time ago, even months, and the server 
>> settings may have changed.  Thus sending what mount used seems 
>> inherently unreliable.  The race window is enormous!

> hmm... I must be missing something... Why is umount-ing with the
> same network protocol that mount used unreliable and racy?

Well, I exaggerated a bit, but technically speaking it is a race window 
because the client is caching information about the server.  When a 
mount succeeds, the client remembers the transport protocol it used for 
the mount in /etc/mtab.

A long time later, it uses that cached information to set the transport 
protocol for the umount request.

During the time the share is mounted (ie the window), some system 
administrator can change the server's settings -- for example, by 
disabling the TCP mountd service, or by changing the iptables on the 
server.  At that point, the information in the client's /etc/mtab 
becomes stale, and, in fact, useless as a hint.

I'm simply arguing that /etc/mtab should be ignored by umount entirely 
when it comes to determining what transport protocol to use because that 
cached information in not reliable.  Just do a fresh GETPORT before the 
umount, and you will be all set.

--------------030701050208010504000505
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------030701050208010504000505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030701050208010504000505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030701050208010504000505--
