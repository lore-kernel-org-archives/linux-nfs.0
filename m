From: David Warren <warren@atmos.washington.edu>
Subject: Re: NFS caching bug is back
Date: Thu, 19 Apr 2007 11:06:47 -0700
Message-ID: <4627AFB7.2080602@atmos.washington.edu>
References: <46278E27.8050705@atmos.washington.edu>
	<4627980C.2090308@serpentine.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0446911414=="
Cc: nfs@lists.sourceforge.net
To: "Bryan O'Sullivan" <bos@serpentine.com>,
	trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Heb28-0007aj-K7
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:07:04 -0700
Received: from dew2.atmos.washington.edu ([128.95.89.42])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Heb29-0006V8-P6
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:07:07 -0700
In-Reply-To: <4627980C.2090308@serpentine.com>
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
--===============0446911414==
Content-Type: multipart/alternative;
	boundary="------------030509090107030808020708"

This is a multi-part message in MIME format.
--------------030509090107030808020708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

No it doesn't. I just let the changed file sit for about 45 minutes and 
the inode still has not changed. It is very similar to a bug I sent in 
for 2.6.11 that had been fixed.

I have also now verified that the same thing happens with a Solaris 10 
client, so it is likely to be the server side.

 From wireshark I see the client sending packets with:
PUTFH and GETATTR
then at the end
PUTFH and ACCESS

The return values for the ACCESS are:
access: 0x2d
.... .1 = allow READ
.... 0. = not allow LOOKUP
...1 .. = allow MODIFY
..1. .. = allow EXTEND
.0.. .. = not allow DELETE
1... .. = allow EXECUTE
The request had
Supported: 0x1f
.... .1 = allow READ
.... 1. = allow LOOKUP
...1 .. = allow MODIFY
..1. .. = allow EXTEND
.1.. .. = allow DELETE
0... .. = allow EXECUTE
Access: 0x1f
.... .1 = allow READ
.... 1. = allow LOOKUP
...1 .. = allow MODIFY
..1. .. = allow EXTEND
.1.. .. = allow DELETE
0... .. = allow EXECUTE

I don't know that much about the inner workings of the NFS protocol, but 
considering that the inode has been removed and replaced by a new one 
shouldn't all the return values from the access request be 0? It seems 
odd that read, modify, extend and execute are allowed for a nonexistent 
object.

Bryan O'Sullivan wrote:
> David Warren wrote:
>> A bug that we turned in a while ago is back in the 2.6.20 kernels, 
>> only worse. I have found it in 2.6.20.6 and 2.6.20.7.
>
> These symptoms look similar to this bug:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=8305
>
> Which has been around since 2.6.17.  Do you find that the problem 
> magically resolves itself after a little while?
>
>     <b

Trond Myklebust wrote:
> On Thu, 2007-04-19 at 08:43 -0700, David Warren wrote:
>   
>> A bug that we turned in a while ago is back in the 2.6.20 kernels,
>> only worse. I have found it in 2.6.20.6 and 2.6.20.7. It happens with
>> both NFS4 and NFS3 mounts. Clients don't see inode changes (delete and
>> recreate file):
>>     
>
> Interesting. Do you see an OPEN request being sent to the server when
> you 'cat' the file on enkf2 or enkf3? You can check either using
> ethereal/wireshark, or by comparing the values in the OPEN column
> in /proc/self/mountstats on the client before and after issuing the
> 'cat' command.
>
> Trond


-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair


--------------030509090107030808020708
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
No it doesn't. I just let the changed file sit for about 45 minutes and
the inode still has not changed. It is very similar to a bug I sent in
for 2.6.11 that had been fixed. <br>
<br>
I have also now verified that the same thing happens with a Solaris 10
client, so it is likely to be the server side.<br>
<br>
>From wireshark I see the client sending packets with:<br>
PUTFH and GETATTR<br>
then at the end<br>
PUTFH and ACCESS<br>
<br>
The return values for the ACCESS are:<br>
access: 0x2d<br>
.... .1 = allow READ<br>
.... 0. = not allow LOOKUP<br>
...1 .. = allow MODIFY<br>
..1. .. = allow EXTEND<br>
.0.. .. = not allow DELETE<br>
1... .. = allow EXECUTE<br>
The request had<br>
Supported: 0x1f<br>
.... .1 = allow READ<br>
.... 1. = allow LOOKUP<br>
...1 .. = allow MODIFY<br>
..1. .. = allow EXTEND<br>
.1.. .. = allow DELETE<br>
0... .. = allow EXECUTE<br>
Access: 0x1f<br>
.... .1 = allow READ<br>
.... 1. = allow LOOKUP<br>
...1 .. = allow MODIFY<br>
..1. .. = allow EXTEND<br>
.1.. .. = allow DELETE<br>
0... .. = allow EXECUTE<br>
<br>
I don't know that much about the inner workings of the NFS protocol,
but considering that the inode has been removed and replaced by a new
one shouldn't all the return values from the access request be 0? It
seems odd that read, modify, extend and execute are allowed for a
nonexistent object.<br>
<br>
Bryan O'Sullivan wrote:
<blockquote cite="mid4627980C.2090308@serpentine.com" type="cite">David
Warren wrote:
  <br>
  <blockquote type="cite">A bug that we turned in a while ago is back
in the 2.6.20 kernels, only worse. I have found it in 2.6.20.6 and
2.6.20.7.
    <br>
  </blockquote>
  <br>
These symptoms look similar to this bug:
  <br>
  <br>
<a class="moz-txt-link-freetext" href="http://bugzilla.kernel.org/show_bug.cgi?id=8305">http://bugzilla.kernel.org/show_bug.cgi?id=8305</a>
  <br>
  <br>
Which has been around since 2.6.17.&nbsp; Do you find that the problem
magically resolves itself after a little while?
  <br>
  <br>
&nbsp;&nbsp;&nbsp;&nbsp;&lt;b
  <br>
</blockquote>
<br>
Trond Myklebust wrote:
<blockquote cite="mid1177000571.6663.25.camel@heimdal.trondhjem.org"
 type="cite">
  <pre wrap="">On Thu, 2007-04-19 at 08:43 -0700, David Warren wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">A bug that we turned in a while ago is back in the 2.6.20 kernels,
only worse. I have found it in 2.6.20.6 and 2.6.20.7. It happens with
both NFS4 and NFS3 mounts. Clients don't see inode changes (delete and
recreate file):
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Interesting. Do you see an OPEN request being sent to the server when
you 'cat' the file on enkf2 or enkf3? You can check either using
ethereal/wireshark, or by comparing the values in the OPEN column
in /proc/self/mountstats on the client before and after issuing the
'cat' command.

Trond</pre>
</blockquote>
<br>
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

--------------030509090107030808020708--


--===============0446911414==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0446911414==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0446911414==--
