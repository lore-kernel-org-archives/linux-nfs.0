From: Kris Vassallo <kris@linuxcertified.com>
Subject: Stale File handles keep coming back
Date: Mon, 25 Apr 2005 14:07:33 -0700
Message-ID: <1114463253.2487.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-USNP2UU1IfoWbWj8WrJP"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQAo7-0001t7-9N
	for nfs@lists.sourceforge.net; Mon, 25 Apr 2005 14:07:55 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DQAnr-0001kH-E2
	for nfs@lists.sourceforge.net; Mon, 25 Apr 2005 14:07:55 -0700
Received: from [10.113.1.100] (morpheus.berkeley-da.com [66.134.41.194])
	(authenticated bits=0)
	by meteor.hosting4less.com (8.12.10/8.12.8) with ESMTP id j3PKmbnl001258
	for <nfs@lists.sourceforge.net>; Mon, 25 Apr 2005 13:48:37 -0700
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


--=-USNP2UU1IfoWbWj8WrJP
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I am experiencing a problem with stale file handles, and I have not been
able to find an answer in the archives nor has doing anything in the
readme helped. I apologize if an answer has already been posted
regarding an issue such as this. After many frustrating hours of
troubleshooting I am hoping for some help. The mail is long but I am
hoping that it answers all the questions. 
    
    I am experiencing the following problem: I have a group of  ~20 nfs
clients (2.4.22-1.2115.nptlsmp) which are all mounting a /home directory
off of 1 NFS server (2.6.11-1.14_FC3smp); the server was upgraded FROM
2.4.22-1.2115.nptlsmp last week. All servers are running NFS v3 over
UDP. 
    As soon as I did the upgrade people started getting stale file
handles, so I shut down all clients and the server, booted the server
back up and then brought the clients back up so that everything would be
in sync. However, this did not resolve the issue. 
    I now have people complaining that if they do a ls in a specific
directory within their home directory, (this happens for all users in
their own private home directory, which I believe rules out the issue of
having someone else manipulating the file) they get an error thats says:
ls: .: Stale NFS file handle .

    *What I don't understand is that if you were to touch a file within
that directory, all of a sudden the contents of the directory magically
become visible.  Removing the directory, recopying the directory back,
and then using for a while works but then all of a sudden it goes stale
again!! 

The following is the content of my /etc/exports
/home        10.113.1.0/26(sync,rw,no_wdelay,no_root_squash) \
                10.113.1.64/26(sync,no_wdelay,rw) \
                10.113.1.128/26(sync,no_wdelay,rw) \
                10.113.1.192/26(sync,no_wdelay,rw)

Clients mount the share with defaults. 

I am not changing anything in the /etc/exports file. The directory has
not actally been deleted as I can go to the server and do a ls on the
directory and see the contents of it (strangely this makes the stale
file handle go away). I have just added no_subtree_check to the exports
file and have not yet tested this. We have not hot swapped any hard
disks in our RAID array. This is an ext3 file system which I believe
supports permanent inode numbers. This is really weird and I can't think
of anything that would cause this but something with nfs and the 2.6.11
kernel?

Please CC me on any responses.
Thank you very much in advance for any help. 
-Kris


--=-USNP2UU1IfoWbWj8WrJP
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.10">
</HEAD>
<BODY>
I am experiencing a problem with stale file handles, and I have not been able to find an answer in the archives nor has doing anything in the readme helped. I apologize if an answer has already been posted regarding an issue such as this. After many frustrating hours of troubleshooting I am hoping for some help. The mail is long but I am hoping that it answers all the questions. <BR>
&nbsp;&nbsp;&nbsp; <BR>
&nbsp;&nbsp;&nbsp; I am experiencing the following problem: I have a group of&nbsp; ~20 nfs clients (2.4.22-1.2115.nptlsmp) which are all mounting a /home directory off of 1 NFS server (2.6.11-1.14_FC3smp); the server was upgraded FROM 2.4.22-1.2115.nptlsmp last week. All servers are running NFS v3 over UDP. <BR>
&nbsp;&nbsp;&nbsp; As soon as I did the upgrade people started getting stale file handles, so I shut down all clients and the server, booted the server back up and then brought the clients back up so that everything would be in sync. However, this did not resolve the issue. <BR>
&nbsp;&nbsp;&nbsp; I now have people complaining that if they do a ls in a specific directory within their home directory, (this happens for all users in their own private home directory, which I believe rules out the issue of having someone else manipulating the file) they get an error thats says<FONT SIZE="3">: </FONT><FONT SIZE="2">ls: .: Stale NFS file handle</FONT><FONT SIZE="3"> .<BR>
<BR>
&nbsp;&nbsp;&nbsp; *What I don't understand is that if you were to touch a file within that directory, all of a sudden the contents of the directory magically become visible.&nbsp; Removing the directory, recopying the directory back, and then using for a while works but then all of a sudden it goes stale again!! <BR>
<BR>
The following is the content of my /etc/exports<BR>
/home&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10.113.1.0/26(sync,rw,no_wdelay,no_root_squash) \<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10.113.1.64/26(sync,no_wdelay,rw) \<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10.113.1.128/26(sync,no_wdelay,rw) \<BR>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 10.113.1.192/26(sync,no_wdelay,rw)<BR>
<BR>
Clients mount the share with defaults. <BR>
<BR>
I am not changing anything in the /etc/exports file. The directory has not actally been deleted as I can go to the server and do a ls on the directory and see the contents of it (strangely this makes the stale file handle go away). I have just added no_subtree_check to the exports file and have not yet tested this. We have not hot swapped any hard disks in our RAID array. This is an ext3 file system which I believe supports permanent inode numbers. This is really weird and I can't think of anything that would cause this but something with nfs and the 2.6.11 kernel?<BR>
<BR>
Please CC me on any responses.<BR>
Thank you very much in advance for any help. <BR>
-Kris<BR>
</FONT><BR>
</BODY>
</HTML>

--=-USNP2UU1IfoWbWj8WrJP--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
