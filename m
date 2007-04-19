From: David Warren <warren@atmos.washington.edu>
Subject: Re: NFS caching bug is back
Date: Thu, 19 Apr 2007 12:52:37 -0700
Message-ID: <4627C885.6040100@atmos.washington.edu>
References: <46278E27.8050705@atmos.washington.edu>	
	<4627980C.2090308@serpentine.com>
	<4627AFB7.2080602@atmos.washington.edu>
	<1177006975.6623.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0029409613=="
Cc: Bryan O'Sullivan <bos@serpentine.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HecgW-0001dw-O3
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 12:52:55 -0700
Received: from dew2.atmos.washington.edu ([128.95.89.42])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HecgZ-0003y9-0l
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 12:52:55 -0700
In-Reply-To: <1177006975.6623.8.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--===============0029409613==
Content-Type: multipart/alternative;
	boundary="------------030004080702040802010001"

This is a multi-part message in MIME format.
--------------030004080702040802010001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

One last really odd one.
enkf3:~# ls -al /home/enkf
total 8
drwxr-xr-x  8 root   root     89 Apr 19 12:02 .
drwxr-xr-x  8 root   root     77 Apr 19 08:06 ..
-rw-r--r--  0 root   root      3 Apr 19 12:01 ddd
drwxr-xr-x 15 enkf   enkf   4096 Apr 19 11:14 enkf
drwxrwsr-x  6 daemon daemon   38 Apr 13 11:05 job
drwxr-xr-x  2 root   root      6 Apr 19 11:41 lost+found
drwxr-xr-x  3 torn   root     28 Apr 18 16:02 torn
drwxr-xr-x  8 warren root    151 Apr 18 11:08 warren
drwxrwxr-x  4 enkf   enkf     34 Apr 16 11:15 wrf2

I removed the file from the server here!!!

enkf3:~# cat /home/enkf/ddd
45

but it knows it is gone
enkf3:~# ls -al /home/enkf
total 4
drwxr-xr-x  8 root   root     89 Apr 19 12:48 .
drwxr-xr-x  8 root   root     77 Apr 19 08:06 ..
-rw-r--r--  1 root   root      0 Apr 19 12:39 dd2
drwxr-xr-x 15 enkf   enkf   4096 Apr 19 11:14 enkf
drwxrwsr-x  6 daemon daemon   38 Apr 13 11:05 job
drwxr-xr-x  2 root   root      6 Apr 19 11:41 lost+found
drwxr-xr-x  3 torn   root     28 Apr 18 16:02 torn
drwxr-xr-x  8 warren root    151 Apr 18 11:08 warren
drwxrwxr-x  4 enkf   enkf     34 Apr 16 11:15 wrf2

however it can still cat it
enkf3:~# cat /home/enkf/ddd
45


Trond Myklebust wrote:
> On Thu, 2007-04-19 at 11:06 -0700, David Warren wrote:
>
>   
>> I don't know that much about the inner workings of the NFS protocol,
>> but considering that the inode has been removed and replaced by a new
>> one shouldn't all the return values from the access request be 0? It
>> seems odd that read, modify, extend and execute are allowed for a
>> nonexistent object.
>>     
>
> The filehandle should normally be invalidated and any attempt by the
> client to use it should result in an ESTALE error. The exception would
> be if a hard link to the file still exists somewhere on the filesystem
> (which didn't seem to be the case in your test).
>
> Irrespective of whether or not the file still exists somewhere else, the
> mtime on the parent directory _will_ change when you unlink the file.
> The client is supposed to pick up on this and re-issue a LOOKUP and/or
> OPEN for the file, at which point the server should reply with an ENOENT
> or with the new file and its filehandle in something like your testcase.
>
> My immediate advice would be to take the whole filesystem offline and
> fsck it just in order to be sure that there are no corruption that might
> be confusing the NFS server.
>
> Cheers
>   Trond
>   

-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair


--------------030004080702040802010001
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
One last really odd one.<br>
enkf3:~# ls -al /home/enkf<br>
total 8<br>
drwxr-xr-x&nbsp; 8 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 89 Apr 19 12:02 .<br>
drwxr-xr-x&nbsp; 8 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 77 Apr 19 08:06 ..<br>
-rw-r--r--&nbsp; 0 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3 Apr 19 12:01 ddd<br>
drwxr-xr-x 15 enkf&nbsp;&nbsp; enkf&nbsp;&nbsp; 4096 Apr 19 11:14 enkf<br>
drwxrwsr-x&nbsp; 6 daemon daemon&nbsp;&nbsp; 38 Apr 13 11:05 job<br>
drwxr-xr-x&nbsp; 2 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6 Apr 19 11:41 lost+found<br>
drwxr-xr-x&nbsp; 3 torn&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 28 Apr 18 16:02 torn<br>
drwxr-xr-x&nbsp; 8 warren root&nbsp;&nbsp;&nbsp; 151 Apr 18 11:08 warren<br>
drwxrwxr-x&nbsp; 4 enkf&nbsp;&nbsp; enkf&nbsp;&nbsp;&nbsp;&nbsp; 34 Apr 16 11:15 wrf2<br>
<br>
I removed the file from the server here!!!<br>
<br>
enkf3:~# cat /home/enkf/ddd<br>
45<br>
<br>
but it knows it is gone<br>
enkf3:~# ls -al /home/enkf<br>
total 4<br>
drwxr-xr-x&nbsp; 8 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 89 Apr 19 12:48 .<br>
drwxr-xr-x&nbsp; 8 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 77 Apr 19 08:06 ..<br>
-rw-r--r--&nbsp; 1 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 Apr 19 12:39 dd2<br>
drwxr-xr-x 15 enkf&nbsp;&nbsp; enkf&nbsp;&nbsp; 4096 Apr 19 11:14 enkf<br>
drwxrwsr-x&nbsp; 6 daemon daemon&nbsp;&nbsp; 38 Apr 13 11:05 job<br>
drwxr-xr-x&nbsp; 2 root&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 6 Apr 19 11:41 lost+found<br>
drwxr-xr-x&nbsp; 3 torn&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 28 Apr 18 16:02 torn<br>
drwxr-xr-x&nbsp; 8 warren root&nbsp;&nbsp;&nbsp; 151 Apr 18 11:08 warren<br>
drwxrwxr-x&nbsp; 4 enkf&nbsp;&nbsp; enkf&nbsp;&nbsp;&nbsp;&nbsp; 34 Apr 16 11:15 wrf2<br>
<br>
however it can still cat it<br>
enkf3:~# cat /home/enkf/ddd<br>
45<br>
<br>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1177006975.6623.8.camel@heimdal.trondhjem.org"
 type="cite">
  <pre wrap="">On Thu, 2007-04-19 at 11:06 -0700, David Warren wrote:

  </pre>
  <blockquote type="cite">
    <pre wrap="">I don't know that much about the inner workings of the NFS protocol,
but considering that the inode has been removed and replaced by a new
one shouldn't all the return values from the access request be 0? It
seems odd that read, modify, extend and execute are allowed for a
nonexistent object.
    </pre>
  </blockquote>
  <pre wrap=""><!---->
The filehandle should normally be invalidated and any attempt by the
client to use it should result in an ESTALE error. The exception would
be if a hard link to the file still exists somewhere on the filesystem
(which didn't seem to be the case in your test).

Irrespective of whether or not the file still exists somewhere else, the
mtime on the parent directory _will_ change when you unlink the file.
The client is supposed to pick up on this and re-issue a LOOKUP and/or
OPEN for the file, at which point the server should reply with an ENOENT
or with the new file and its filehandle in something like your testcase.

My immediate advice would be to take the whole filesystem offline and
fsck it just in order to be sure that there are no corruption that might
be confusing the NFS server.

Cheers
  Trond
  </pre>
</blockquote>
<br>
<pre class="moz-signature" cols="72">-- 
David Warren 		INTERNET: <a class="moz-txt-link-abbreviated" href="mailto:warren@atmos.washington.edu">warren@atmos.washington.edu</a>
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair
</pre>
</body>
</html>

--------------030004080702040802010001--


--===============0029409613==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0029409613==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0029409613==--
