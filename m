From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: NFS lock recovery problem if subtree_check option used
Date: Fri, 19 Nov 2004 03:10:03 -0800 (PST)
Message-ID: <20041119111003.52425.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hi , 
     I am facing new problem in NFS lock krecovery
      on sles9 sp1 beta2 release.
     This problem was not there in slses9 rc5 
     release.
PROBLEM:

NFS stale handle error if client tries to reclaim lock
for filesystem exported with subtree_check option

DESCRIPTION:

1.I exported whole filesystem to client using rw ,
  no_root_squash option.By default subtree_check
  option is enabled.
2.When server restarts and client tries to
  reclaim lock , it gets NFS_STALE_FH error.
3.If server exports filesystem system with
  additional option no_subtree_check client then
  faces no problems.
4.Problem is in function nfs_acceptable
  function(nfsfh.c) or functions calling
  nfs_acceptable function.This function somehow
  returns 0 which means invalid handle.
5.Message in /var/log/message file
   "nfs_acceptable failed at ...."


HOW TO SETUP:

1.Set up two systems with a shared disk
2.start nfs server on first system and export
  filesystem present on shared disk to client
  with rw,no_root_squash  option.
3.Let client reclaim lock .
4.Stop nfs server on first system before client
  releases lock.
5.Now  , start nfs server on second system.
6.Client gets NFS_STALE_FH error when it tries
  to reclaim lock

  If i am missing anything or somebody else
  is facing same problem please let me know.
thanks,
   kiran


		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - Get yours free! 
http://my.yahoo.com 
 



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
