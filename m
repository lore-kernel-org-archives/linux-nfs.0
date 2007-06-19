From: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
Subject: Re: Permission information on the directory is output with ?
Date: Tue, 19 Jun 2007 17:24:55 +0900
Message-ID: <20070619172455.e8be4d49.s-sagawa@jp.fujitsu.com>
References: <20070524175934.17a59a57.s-sagawa@jp.fujitsu.com>
	<75A58A7C14469A45BA7A50CDC34EBCF806272180@tlaexc01.asiapacific.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Phrukphicharn, Anuwat" <anuwat@hp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0Z1d-0006VU-It
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 01:25:21 -0700
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I0Z1e-0001Pb-DJ
	for nfs@lists.sourceforge.net; Tue, 19 Jun 2007 01:25:24 -0700
In-Reply-To: <75A58A7C14469A45BA7A50CDC34EBCF806272180@tlaexc01.asiapacific.cpqcorp.net>
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

Hello Phrukphicharn,

On Wed, 13 Jun 2007 15:44:29 +0700
"Phrukphicharn, Anuwat" <anuwat@hp.com> wrote:

> Hello Shunichi,
> 
> I have run the test case for some time, but could not produce such the
> symptom (may be I did something wrong). 

I'm sorry, my information was insufficient.

- "/var/spool/postfix" directory exists on a NFS client disk.
- The directory right under "/var/spool/postfix" directory has been linked
  to the directory of the NFS server area.

# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda8             19931708  13541004   5378212  72% /
none                    516972         0    516972   0% /dev/shm
/dev/sdb1             70557052  43613868  23359088  66% /work
rhas4up3-part2:/vol/vol0/jpmail
                       8143616   4978656   2751296  65% /po
# ls -ld /var/spool/postfix/
drwxr-xr-x  16 root root 4096 May 21 14:44 /var/spool/postfix/
# ls -l /var/spool/postfix/ | grep incoming
lrwxrwxrwx  1 postfix root       34 May 21 14:44 incoming -> ../../../po/spool/postfix/incoming
#

There are some other symbolic links, which are "active", "bounce",
"corrupt", "defer", "deferred", "flush", "hold", "maildrop", "saved",
"trace", like the link "incoming".

And, this problem occurs in a few seconds by the following method.
(A) postfix execute.
  [root@hazard ~]# telnet localhost 25
  Trying 127.0.0.1...
  Connected to localhost.localdomain (127.0.0.1).
  Escape character is '^]'.
  220 hazard.soft.fujitsu.com ESMTP Postfix
  helo soft.fujitsu.com
  250 hazard.soft.fujitsu.com
  mail from: s-sagawa@jp.fujitsu.com
  250 Ok
  rcpt to: s-sagawa@jp.fujitsu.com
  250 Ok
  quit

(B) nfs umount/mount.
  [root@hazard ~]# df -TH
  Filesystem    Type     Size   Used  Avail Use% Mounted on
  /dev/sda8     ext3      21G    14G   5.8G  71% /
  none         tmpfs     530M      0   530M   0% /dev/shm
  /dev/sdb1     ext3      73G    45G    24G  66% /work
  rhas4up3-part2:/vol/vol0/jpmail
                 nfs     8.4G   5.1G   2.9G  65% /po
  [root@hazard ~]# umount /po
  [root@hazard ~]# df -TH | grep nfs
  [root@hazard ~]# mount /po
  [root@hazard ~]# df -TH | grep nfs
                 nfs     8.4G   5.1G   2.9G  65% /po
  [root@hazard ~]#

(C) postfix execute.
  [root@hazard ~]# telnet localhost 25
  Trying 127.0.0.1...
  Connected to localhost.localdomain (127.0.0.1).
  Escape character is '^]'.
  220 hazard.soft.fujitsu.com ESMTP Postfix
  helo soft.fujitsu.com
  250 hazard.soft.fujitsu.com
  mail from: s-sagawa@jp.fujitsu.com
  250 Ok
  rcpt to: s-sagawa@jp.fujitsu.com

When "250 OK" is not output, "ls -l /po/spool/postfix" is executed.

And, this problem occurs on the following condition.
(1) Access nfs directory through symbolic link, which links to the nfs directory.
    For example, access "/var/spool/postfix/incoming". and
(2) O_EXCL is specified for the argument of open(2).
This problem did not occur when I changed(queue_directory of /etc/postfix/main.c)
"/var/spool/postfix" to "/po/spool/postfix".

> Btw, I have worked with this symptom on RHEL4, BZ 228801. 

Oh, I see.

> Which the issue is on the client side. You
> may want to check otw attributes of the "incoming" in a GETATTR reply
> (for example) if that is correct. I remember that if 'ls -l' think that
> an attribute value is not valid it will print "?" or other case is it
> cannot retrieve attribute of the file via 'stat("file") call. Which
> latter is my case that the client keeps negative dentry and never
> invalidate it (as a result, a stat() returns ENOENT as the nfs dentry
> revalidation code thinks that it is still valid (so no inode allocated
> for the dentry) while the file is already exist on the server).

Thank you for your detailed information.
The "BZ 228801" phenomena is same(no inode allocated for the dentry) with my problem.
But, I think that the cause of my problem and BZ 228801 is different.

I confirmed my problem and corrected it by the following patches. :-)
  (1) RHEL4 UP1 base-kernel.
  (2) Fix following patch(Fix RHEL4 UP2(nfs)).
      linux-2.6.9-nfs-estale.patch
  (3) http://linux-nfs.org/Linux-2.6.x/2.6.12-rc6/linux-2.6.12-02-fix_O_EXCL.dif

Thank you.

Regards,
Sagawa

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
