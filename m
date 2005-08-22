From: Mason Sanders <mason@castlebranch.com>
Subject: Secure NFS File Share Problem
Date: Mon, 22 Aug 2005 17:45:07 -0400
Message-ID: <1124747108.2642.24.camel@mason.castlebranch.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-XpdkAzGMyzFKzPepQdB0"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E7K6P-0000CI-IK
	for nfs@lists.sourceforge.net; Mon, 22 Aug 2005 14:45:09 -0700
Received: from proxy1.castlebranch.com ([66.21.56.81])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E7K6P-000743-5l
	for nfs@lists.sourceforge.net; Mon, 22 Aug 2005 14:45:09 -0700
To: nfs@lists.sourceforge.net
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


--=-XpdkAzGMyzFKzPepQdB0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello,

I have an LDAP based network with several Cent OS 4 file servers and
many Fedora Core 2 client machines.  I want to set up NFS on one of them
in the following configuration and I can't seem to make it work.

I have the following directory structure and I want to lock it down:

/public
/public/sales
/public/operations
/public/hr
/public/acct

Basically I want each department to be able to access only their files.
I also want all files that are created in these directories to be able
to be modified by everyone in the respective group.  I currently have
this setup functional with samba, but since my clients are now all linux
based, I would like to use nfs.  Here is an example from my smb.conf
that accomplishes what I want:

 [acct]
   comment = Accounting Administration Share
   writable = yes
   path = /public/acct
   sync always = yes
   valid users = @acct
   force group = acct
   create mode = 0660
   directory mode = 0770
   public = no
   browseable = no


Is there a way to do this with nfs?  My /etc/exports on the server looks
like this:

/public/acct
192.168.2.0/255.255.255.0(rw,sync,all_squash,anonuid=510,anongid=601)

This works in that all files are created as the same user and can be
modified by anyone, but access is not limited to the acct group.  When I
change the entry to 

/public/acct           @acct(rw,sync,all_squash,anonuid=510,anongid=601)

It then denies access to anyone not in the acct posix group in LDAP, but
whenever a user creates a file in the share, it is owned by that user
with their primary group with permissions of 0644.  My anonymous uid and
gid are ignored!  Now access to the files is restricted to the acct
group, but the files are only able to be modified by their owner.  I
could change the umask to 002 on all of my clients, but then this opens
up security problems elsewhere, most notably in one's home directory.

Any help with this would be appreciated.

Thanks,

Mason Sanders

--=-XpdkAzGMyzFKzPepQdB0
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.6.2">
</HEAD>
<BODY>
Hello,<BR>
<BR>
I have an LDAP based network with several Cent OS 4 file servers and many Fedora Core 2 client machines.&nbsp; I want to set up NFS on one of them in the following configuration and I can't seem to make it work.<BR>
<BR>
I have the following directory structure and I want to lock it down:<BR>
<BR>
/public<BR>
/public/sales<BR>
/public/operations<BR>
/public/hr<BR>
/public/acct<BR>
<BR>
Basically I want each department to be able to access only their files.&nbsp; I also want all files that are created in these directories to be able to be modified by everyone in the respective group.&nbsp; I currently have this setup functional with samba, but since my clients are now all linux based, I would like to use nfs.&nbsp; Here is an example from my smb.conf that accomplishes what I want:<BR>
<BR>
 [acct]<BR>
&nbsp;&nbsp; comment = Accounting Administration Share<BR>
&nbsp;&nbsp; writable = yes<BR>
&nbsp;&nbsp; path = /public/acct<BR>
&nbsp;&nbsp; sync always = yes<BR>
&nbsp;&nbsp; valid users = @acct<BR>
&nbsp;&nbsp; force group = acct<BR>
&nbsp;&nbsp; create mode = 0660<BR>
&nbsp;&nbsp; directory mode = 0770<BR>
&nbsp;&nbsp; public = no<BR>
&nbsp;&nbsp; browseable = no<BR>
<BR>
<BR>
Is there a way to do this with nfs?&nbsp; My /etc/exports on the server looks like this:<BR>
<BR>
/public/acct&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 192.168.2.0/255.255.255.0(rw,sync,all_squash,anonuid=510,anongid=601)<BR>
<BR>
This works in that all files are created as the same user and can be modified by anyone, but access is not limited to the acct group.&nbsp; When I change the entry to <BR>
<BR>
/public/acct&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; @acct(rw,sync,all_squash,anonuid=510,anongid=601)<BR>
<BR>
It then denies access to anyone not in the acct posix group in LDAP, but whenever a user creates a file in the share, it is owned by that user with their primary group with permissions of 0644.&nbsp; My anonymous uid and gid are ignored!&nbsp; Now access to the files is restricted to the acct group, but the files are only able to be modified by their owner.&nbsp; I could change the umask to 002 on all of my clients, but then this opens up security problems elsewhere, most notably in one's home directory.<BR>
<BR>
Any help with this would be appreciated.<BR>
<BR>
Thanks,<BR>
<BR>
Mason Sanders
</BODY>
</HTML>

--=-XpdkAzGMyzFKzPepQdB0--



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
