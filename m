From: Anders Widman <andewid@tnonline.net>
Subject: Re: NFS problems..
Date: Tue, 3 Sep 2002 18:33:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <11932855312.20020903183326@tnonline.net>
References: <6330918750.20020903180110@tnonline.net>
 <200209031812.29589.bernd-schubert@web.de>
Reply-To: Anders Widman <andewid@tnonline.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from s20.dknet.se ([62.65.10.55] helo=lka.nu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mGdJ-000312-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 09:34:29 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <200209031812.29589.bernd-schubert@web.de>
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

> Hi,

> I'm afraid exporting subfolders of an already exported directory doesn't work, 
> and so it doesn't when you try to export vice versa.

I  read  that  also.. but only exporting / (root) doesn't work either.
That is my real problem.

//Anders

> Regards, Bernd

> On Tuesday 03 September 2002 18:01, Anders Widman wrote:
>>    Hello!
>>
>>    Running  RedHat  7.3  I  am  trying  to  use NFS to export root. It
>>    doesn't  work.  Exporting any subfolder works... This is my exports
>>    file:
>>
>>        /usr/src/       192.168.0.100(rw,no_root_squash,insecure)
>>        /               192.168.0.100(rw,no_root_squash,insecure)
>>
>>    When using "exportfs -a" I get an error:
>>
>>        192.168.0.100:/: Invalid argument
>>
>>    Then, when I am trying to mount from the client:
>>
>>        mount -tnfs 192.168.0.101:/mnt/root/ /mnt/server/
>>        mount: 192.168.0.101:/mnt/root/ failed, reason given by server:
>> Permission denied
>>
>>    And the server syslog contains this:
>>
>>        rpc.mountd: authenticated mount request from 192.168.0.100:752 for /
>> (/) rpc.mountd: getfh failed: Operation not permitted
>>
>>    What am I doing wrong?
>>
>>     - Anders
>>
>>
>>
>> -------------------------------------------------------
>> This sf.net email is sponsored by: OSDN - Tired of that same old
>> cell phone?  Get a new here for FREE!
>> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
