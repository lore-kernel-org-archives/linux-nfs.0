From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: Corrupt Data when using NFS on Linux
Date: Tue, 29 Oct 2002 11:03:15 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210291703.g9TH3FD32594@leinie.lmcg.wisc.edu>
References: <6440EA1A6AA1D5118C6900902745938E07D54FE2@black.eng.netapp.com> <007601c27ed6$74986240$2864a8c0@alanw>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Zlt-0006sa-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 09:03:17 -0800
To: "Alan Witz" <awitz@magstarinc.com>
In-reply-to: <007601c27ed6$74986240$2864a8c0@alanw> (awitz@magstarinc.com)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Alan,

>> The operating environment is Red Hat Linux 2.4.18-17.7.xsmp.  We
>> are running NFS version 3.  We have implemented some of our own
>> rudimentary file locking techniques to try and circumvent the
>> problem.  This consists of creating a lock file which acts as a
>> flag which tells the other clients not to access the file.
>> Basically, if the lock file exists then the other clients will wait
>> until the file is cleared before writing to the database file.  To
>> ensure that this works properly the "lock" flag is being created
>> using the "ln" command so that the process of checking for a lock
>> and setting a lock is essentially done in one step (thus
>> eliminating the possibility of another client setting the lock
>> after the current client has checked for the lock but before it can
>> set the lock itself).  We are also running NFS in synchronous mode
>> to try and reduce the chances of data corruption due to multiple
>> clients.  The mount options are as follows:
>> 
>>     rsize=8192,wsize=8192,noac,hard,sync,nfsvers=3
>> 
>> Any thoughts would be greatly appreciated.

You need to be careful when creating your lock files.

The "guaranteed" way to create a lock file over NFS:

    create tempfile
    link tempfile lockfile (ignore return code)
    stat tempfile

If the link count is 2, then you have the lock file.  Apparently, link
may return success even if the link failed or return failure even if
the link succeeded (I don't remember which).  Doing the stat verifies
if you have actually created a link to the temporary file.  While I
have never seen this problem, the people who do mailbox locking have
documented this as a problem over NFS.

Also, you will have to use "fcntl" locking if you want to ensure the
data you are reading is consistent.  Doing a "lockf(fd, F_LOCK, 0)"
will guarantee that data written by other clients has been written to
the file and clear the client cache.  Of course, now that you're using
"fcntl" locking for this, you can probably get rid of the lock file.

-- 
+----------------------------------+----------------------------------+
| Daniel K. Forrest                | Laboratory for Molecular and     |
| forrest@lmcg.wisc.edu            | Computational Genomics           |
| (608)262-9479                    | University of Wisconsin, Madison |
+----------------------------------+----------------------------------+


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
