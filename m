From: Anders Widman <andewid@tnonline.net>
Subject: Re: NFS problems..
Date: Tue, 3 Sep 2002 21:11:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <17742334796.20020903211126@tnonline.net>
References: <6330918750.20020903180110@tnonline.net>
 <200209031812.29589.bernd-schubert@web.de>
 <11932855312.20020903183326@tnonline.net>
 <200209032058.50830.bernd-schubert@web.de>
Reply-To: Anders Widman <andewid@tnonline.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from s20.dknet.se ([62.65.10.55] helo=lka.nu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mJ6E-0000nN-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 12:12:30 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200209032058.50830.bernd-schubert@web.de>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> On Tuesday 03 September 2002 18:33, Anders Widman wrote:
>> > Hi,
>> >
>> > I'm afraid exporting subfolders of an already exported directory doesn't
>> > work, and so it doesn't when you try to export vice versa.
>>
>> I  read  that  also.. but only exporting / (root) doesn't work either.
>> That is my real problem.
>>
>> //Anders
>>

> Ah, now I understand. 

>> /                192.168.0.100(rw,no_root_squash,insecure)

> Is '/' perhaps already an imported directory? 


What  do  you  mean by "imported directory".. This is my FSTAB file on
the server:

/dev/hde2       /                      reiserfs defaults        1 1
/dev/hde1       /boot                  ext3     defaults        1 2
none            /dev/pts               devpts   gid=5,mode=620  0 0
none            /proc                  proc     defaults        0 0
none            /dev/shm               tmpfs    defaults        0 0
/dev/hde3       swap                   swap     defaults        0 0



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
