From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: NFS problems..
Date: Tue, 3 Sep 2002 18:12:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209031812.29589.bernd-schubert@web.de>
References: <6330918750.20020903180110@tnonline.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mGI7-0004ww-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 09:12:36 -0700
To: Anders Widman <andewid@tnonline.net>
In-Reply-To: <6330918750.20020903180110@tnonline.net>
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

Hi,

I'm afraid exporting subfolders of an already exported directory doesn't work, 
and so it doesn't when you try to export vice versa.

Regards, Bernd

On Tuesday 03 September 2002 18:01, Anders Widman wrote:
>    Hello!
>
>    Running  RedHat  7.3  I  am  trying  to  use NFS to export root. It
>    doesn't  work.  Exporting any subfolder works... This is my exports
>    file:
>
>        /usr/src/       192.168.0.100(rw,no_root_squash,insecure)
>        /               192.168.0.100(rw,no_root_squash,insecure)
>
>    When using "exportfs -a" I get an error:
>
>        192.168.0.100:/: Invalid argument
>
>    Then, when I am trying to mount from the client:
>
>        mount -tnfs 192.168.0.101:/mnt/root/ /mnt/server/
>        mount: 192.168.0.101:/mnt/root/ failed, reason given by server:
> Permission denied
>
>    And the server syslog contains this:
>
>        rpc.mountd: authenticated mount request from 192.168.0.100:752 for /
> (/) rpc.mountd: getfh failed: Operation not permitted
>
>    What am I doing wrong?
>
>     - Anders
>
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Bernd Schubert
Physikalisch Chemisches Institut
Abt. Theoretische Chemie
INF 229, 69120 Heidelberg
Tel.: 06221/54-5210
e-mail: 	bernd (dot) schubert (at) pci (dot) uni-heidelberg (dot) de 


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
