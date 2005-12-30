From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Fcntl F_SETLKW hangs on Linux NFS mount
Date: Fri, 30 Dec 2005 08:42:29 -0500
Message-ID: <43B53945.1060008@RedHat.com>
References: <AB58C1C45C3FD74A9C262584E8F8C16001F001D1@ntxboimbx16.micron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EsKWn-0005qi-3s
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 05:42:41 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EsKWm-00025H-Rb
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 05:42:41 -0800
To: khowe@micron.com
In-Reply-To: <AB58C1C45C3FD74A9C262584E8F8C16001F001D1@ntxboimbx16.micron.com>
Sender: nfs-admin@lists.sourceforge.net
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

khowe@micron.com wrote:
> I'm running into an issue when using fcntl with the F_SETLKW command on 
> a Linux NFS client. In cases where I have many processes all trying to 
> get a write lock at once, the call to fcntl never returns, even though 
> the lock appears to have been granted successfully. It is not a 
> consistent error, but it is fairly repeatable (about 30% of the time). 
> I'm running on a RedHat client, though I'm not exactly sure of the 
> RedHat version. However, the kernel reported by uname is "Linux 
> prblnx-bo04 2.4.21-32.ELsmp #1 SMP Fri Apr 15 21:17:59 EDT 2005 i686 
> i686 i386 GNU/Linux", and it appears to be using v1.0.6 of nfs-utils. 
> The mounts are set via autofs, using automount v4.1.3-130.
> 
> My test program creates 16 process that all try to get a write lock on 
> the same file, and it will frequently fail such that one of the 
> processes appears to have been granted the lock but does not return from 
> the fcntl call (and the remaining processes are then also all stuck). 
> Listing open files and locks using "lsof -N" shows that one of the 
> processes has been granted the W lock, yet this same process does not 
> return from the fcntl call. I have toyed with the mounting options on 
> the client and I am seeing this behavior with NFS v2 and v3, with short 
> or long timeouts (from timeo=7 to timeo=600), with intr and with nointr, 
> and with r and wsize's ranging from 1024 to 32768. The only option I 
> haven't been able to mess with is using TCP instead of UDP, since this 
> particular RedHat build does not seem to allow the TCP option.
> 
> The NFS server for the mount is a vendor provided NAS device, and I'm 
> not sure what its OS or NFS server is. However, the fact that lsof shows 
> the lock has been granted seems to indicate the disconnect is somewhere 
> on the client side after getting the lock but before waking up fcntl. I 
> also run the exact some program on a Solaris host against the same mount 
> and have no issues at all, which also seems to rule out a server-side issue.
> 
> The test program I'm using is a c app compiled with gcc v3.3.1. Any 
> thoughts? 
Using your test program I see there is a window where a GRANT
message can come in before the client has added a the lock request
to the blocked locked list. In this case the status in the
GRANT reply is set to one (i.e. nlm_lck_denied), but the lock will be
retried after a 30sec time out, which can give the appearance
that the app is hung... With my testing, I've simply waited a
period of time and the app always returned....

So we can compare findings, I would like you to post a bzip2-ed
binary tethereal trace. Something like:
     tethereal -w /tmp/data.pcap host <client> and host <server>
     bzip2 /tmp/data.pcap

steved.





-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
