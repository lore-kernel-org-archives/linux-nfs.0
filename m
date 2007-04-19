From: David Warren <warren@atmos.washington.edu>
Subject: Re: NFS caching bug is back - We think we found it
Date: Thu, 19 Apr 2007 14:29:44 -0700
Message-ID: <4627DF48.8080609@atmos.washington.edu>
References: <46278E27.8050705@atmos.washington.edu>	
	<4627980C.2090308@serpentine.com>
	<4627AFB7.2080602@atmos.washington.edu>
	<1177006975.6623.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1685540975=="
Cc: Bryan O'Sullivan <bos@serpentine.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeeCc-0003Sg-FT
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 14:30:06 -0700
Received: from dew2.atmos.washington.edu ([128.95.89.42])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HeeCd-0008LH-PB
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 14:30:09 -0700
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
--===============1685540975==
Content-Type: multipart/alternative;
	boundary="------------010102020200040807090504"

This is a multi-part message in MIME format.
--------------010102020200040807090504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

After more testing, we think we have the answer. It looks like the only 
servers that exhibit this problem are ones that have gfs disks attached. 
Systems with identical kernels except for no gfs, gfs2 or dlm modules do 
not seem to do this. So, something in the gfs modules must be trashing 
some kernel structure that the nfs server uses, even though this is not 
a gfs file system.

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


--------------010102020200040807090504
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
After more testing, we think we have the answer. It looks like the only
servers that exhibit this problem are ones that have gfs disks
attached. Systems with identical kernels except for no gfs, gfs2 or dlm
modules do not seem to do this. So, something in the gfs modules must
be trashing some kernel structure that the nfs server uses, even though
this is not a gfs file system.<br>
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

--------------010102020200040807090504--


--===============1685540975==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1685540975==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1685540975==--
