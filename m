From: John Doshier <john@inter7.com>
Subject: lockd: cannot monitor 192.168.0.31
Date: Fri, 20 Sep 2002 14:33:11 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D8B77F7.1030400@inter7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.inter7.com ([209.218.8.2])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sTXc-00061L-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 12:34:16 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi Everyone,

    I keep seeing this error ever 5 mintues on the console of one of my 
NFS clients..

Sep 20 13:40:00 mailclone1 kernel: lockd: cannot monitor 192.168.0.3
Sep 20 13:45:00 mailclone1 kernel: lockd: cannot monitor 192.168.0.3
Sep 20 13:50:01 mailclone1 kernel: lockd: cannot monitor 192.168.0.3

    I'm running RedHat 7.3 with kernel 2.4.18-10 on both the client and 
server.  I'm using nfs-utils-0.3.3-5.

    I've done some digging and have found quite a few references about 
this same problem.  However, all of the suggested solutions don't seem 
to apply to me.

    One suggestion was to make sure statd/lockd are running on the 
client.  They are, and they are also running on the server.
   
    Another was to check permissions of /var/lib/nfs/statd.  The 
directory is mode 0700 owned by rpcuser.rpcuser, which is the user that 
rpc.statd is running as.


    As far as I can tell everything is working fine with regards to the 
NFS mounts.  The clients mount them no problem, and have no trouble 
reading or writing to them.  I'm just trying to figure out the cause of 
these error's before I move these boxes into production.  I don't want 
to leave any loose ends untied.

    Any help is greatly appreciated.

    Thanks,

        John
   

-- 
John Doshier
Unix Systems Administrator
Inter7 Internet Technologies, INC.
(p) 847.492.0470 (f) 847.492.0632
http://www.inter7.com/main.html




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
