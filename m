From: khowe@micron.com
Subject: RE: Fcntl F_SETLKW hangs on Linux NFS mount
Date: Fri, 30 Dec 2005 08:26:07 -0700
Message-ID: <AB58C1C45C3FD74A9C262584E8F8C16001F001F2@ntxboimbx16.micron.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EsM93-0003VW-50
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 07:26:17 -0800
Received: from masquerade.micron.com ([137.201.242.130])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EsM92-00010M-KU
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 07:26:17 -0800
Received: from mail-srv2.micron.com (localhost [127.0.0.1])
	by masquerade.micron.com (8.12.9/8.12.2) with ESMTP id jBUFQiqh010149
	for <nfs@lists.sourceforge.net>; Fri, 30 Dec 2005 08:26:44 -0700 (MST)
To: <SteveD@redhat.com>
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

>> I'm running into an issue when using fcntl with the F_SETLKW command
on=20
>> a Linux NFS client. In cases where I have many processes all trying
to=20
>> get a write lock at once, the call to fcntl never returns, even
though=20
>> the lock appears to have been granted successfully. It is not a=20
>> consistent error, but it is fairly repeatable (about 30% of the
time).=20
>> I'm running on a RedHat client, though I'm not exactly sure of the=20
>> RedHat version. However, the kernel reported by uname is "Linux=20
>> prblnx-bo04 2.4.21-32.ELsmp #1 SMP Fri Apr 15 21:17:59 EDT 2005 i686=20
>> i686 i386 GNU/Linux", and it appears to be using v1.0.6 of nfs-utils.

>> The mounts are set via autofs, using automount v4.1.3-130.
>>=20
>> My test program creates 16 process that all try to get a write lock
on=20
>> the same file, and it will frequently fail such that one of the=20
>> processes appears to have been granted the lock but does not return
from=20
>> the fcntl call (and the remaining processes are then also all stuck).

>> Listing open files and locks using "lsof -N" shows that one of the=20
>> processes has been granted the W lock, yet this same process does not

>> return from the fcntl call. I have toyed with the mounting options on

>> the client and I am seeing this behavior with NFS v2 and v3, with
short=20
>> or long timeouts (from timeo=3D7 to timeo=3D600), with intr and with
nointr,=20
>> and with r and wsize's ranging from 1024 to 32768. The only option I=20
>> haven't been able to mess with is using TCP instead of UDP, since
this=20
>> particular RedHat build does not seem to allow the TCP option.
>
> Using your test program I see there is a window where a GRANT
> message can come in before the client has added a the lock request
> to the blocked locked list. In this case the status in the
> GRANT reply is set to one (i.e. nlm_lck_denied), but the lock will be
> retried after a 30sec time out, which can give the appearance
> that the app is hung... With my testing, I've simply waited a
> period of time and the app always returned....
>=20
> So we can compare findings, I would like you to post a bzip2-ed
> binary tethereal trace. Something like:
>      tethereal -w /tmp/data.pcap host <client> and host <server>
>      bzip2 /tmp/data.pcap

I have also seen this 30 second timeout behavior while testing, in
addition to the full-fledged hang that I described. In the case of a 30
second timeout, one symptomatic difference is that when I do an lsof -N,
none of the processes show a "W" lock on the file. After 30 seconds, one
of them will apparently retry, get the lock, and all is well. In the
other case, however, an lsof -N shows that one of the processes actually
has a "W" lock on the file, yet it never returns (where "never" is at
least 6 hours or so, which is the longest I've left it in this state).
Anyhow, I will try to get tethereal traces for both of these scenarios.
Thanks...

- Keith


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
