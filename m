From: Christopher T Vogan <cvogan@us.ibm.com>
Subject: Re: FileID size with nfsv3
Date: Fri, 12 Jan 2007 15:30:47 -0600
Message-ID: <OFCF382287.DA9907EB-ON87257261.00753DD3-86257261.0076291E@us.ibm.com>
References: <1168634557.6494.52.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1718391016=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5TzJ-0000xO-P9
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 13:31:01 -0800
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H5TzG-0000BC-VU
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 13:31:00 -0800
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0CLUqFi010000
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 16:30:52 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	l0CLUq5g486300
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 14:30:52 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l0CLUq9n029315
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 14:30:52 -0700
In-Reply-To: <1168634557.6494.52.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

--===============1718391016==
Content-type: multipart/related;
	Boundary="0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43"

--0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: multipart/alternative;
	Boundary="1__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43"

--1__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


Thanks Trond,
So does this mean that Linux on a 64bit system supports 8 byte FileID's=

with NFSv3 now?  Is there a time frame when these patches will be merge=
d
into the mainstream kernel? I am more interested in the client as it is=

connecting to ZFS file sytems on Sun. Snoop tracing showed the FileID w=
as 8
bytes. but I got a message on the linux system  "Value too large for
defined data type". Now this message was produced by the running progra=
m
but i expect that other user tools will have the same issue if they can=
not
handle stat64 calls.
How can I get these patches from Dave?

Christopher Vogan
Dept. W98 NFS Development & Test


                                                                       =
    
             Trond Myklebust                                           =
    
             <trond.myklebust@                                         =
    
             fys.uio.no>                                               =
 To 
                                       Christopher T Vogan/San         =
    
             01/12/2007 02:42          Jose/IBM@IBMUS                  =
    
             PM                                                        =
 cc 
                                       nfs@lists.sourceforge.net       =
    
                                                                   Subj=
ect 
                                       Re: [NFS] FileID size with nfsv3=
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




On Fri, 2007-01-12 at 11:31 -0600, Christopher T Vogan wrote:
>
> I had a question regarding NFSv3 Client and server but was not sure
> who to ask.
> The NFSv3 RFC states that NFSv3 should support 8 byte FILEID's. Does
> Linux
> support 8 byte FILEID's for NFSv3? It seems that most commands do
> support the use of large FileID's but gcc seems to have a problem.
>
> This is what I see in the RFC1813
> File attribute changes from NFSv2.
> The size and fileid fields have been widened to eight-byte unsigned
> integers from four-byte integers.

We don't currently export 64-bit inode numbers to userland on 32-bit
platforms because the code to allow getdents64() and stat64() to deal
with them was only recently merged into the kernel (as of 2.6.19).

I believe that David Howells does have patches that allows NFS to make
use of this new functionality, but he hasn't asked me to push them to
Linus yet. I'm not sure why.

Cheers,
  Trond

=

--1__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Thanks Trond,<br>
So does this mean that Linux on a 64bit system supports 8 byte FileID's=
 with NFSv3 now?  Is there a time frame when these patches will be merg=
ed into the mainstream kernel? I am more interested in the client as it=
 is connecting to ZFS file sytems on Sun. Snoop tracing showed the File=
ID was 8 bytes. but I got a message on the linux system <tt>&nbsp;&quot=
;Value too large for defined data type</tt>&quot;. Now this message was=
 produced by the running program but i expect that other user tools wil=
l have the same issue if they cannot handle stat64 calls. <br>
How can I get these patches from Dave? <br>
<br>
Christopher Vogan<br>
Dept. W98 NFS Development &amp; Test<br>
<img width=3D"16" height=3D"16" src=3D"cid:1__=3D08BBF8F2DFE6BB438f9e8a=
93df938@us.ibm.com" border=3D"0" alt=3D"Inactive hide details for Trond=
 Myklebust &lt;trond.myklebust@fys.uio.no&gt;">Trond Myklebust &lt;tron=
d.myklebust@fys.uio.no&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:2__=3D08BBF8F2=
DFE6BB438f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Trond Myklebust &lt;trond.myklebust@fys.uio.no&=
gt;</font></b><font size=3D"2"> </font>
<p><font size=3D"2">01/12/2007 02:42 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF8F2DFE6BB438f=
9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Christopher T Vogan/San Jose/IBM@IBMUS</font></td></tr=
>

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF8F2DFE6BB438f=
9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">nfs@lists.sourceforge.net</font></td></tr>

<tr valign=3D"top"><td width=3D"1%"><img width=3D"58" height=3D"1" src=3D=
"cid:3__=3D08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D08BBF8F2DFE6B=
B438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Re: [NFS] FileID size with nfsv3</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:3__=3D08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D=
08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>On Fri, 2007-01-12 at 11:31 -0600, Christopher T Vogan wrote:<br>
&gt; <br>
&gt; I had a question regarding NFSv3 Client and server but was not sur=
e<br>
&gt; who to ask.<br>
&gt; The NFSv3 RFC states that NFSv3 should support 8 byte FILEID's. Do=
es<br>
&gt; Linux<br>
&gt; support 8 byte FILEID's for NFSv3? It seems that most commands do<=
br>
&gt; support the use of large FileID's but gcc seems to have a problem.=
 <br>
&gt; <br>
&gt; This is what I see in the RFC1813<br>
&gt; File attribute changes from NFSv2.<br>
&gt; The size and fileid fields have been widened to eight-byte unsigne=
d<br>
&gt; integers from four-byte integers.<br>
<br>
We don't currently export 64-bit inode numbers to userland on 32-bit<br=
>
platforms because the code to allow getdents64() and stat64() to deal<b=
r>
with them was only recently merged into the kernel (as of 2.6.19).<br>
<br>
I believe that David Howells does have patches that allows NFS to make<=
br>
use of this new functionality, but he hasn't asked me to push them to<b=
r>
Linus yet. I'm not sure why.<br>
<br>
Cheers,<br>
 &nbsp;Trond<br>
<br>
</tt><br>
</body></html>=


--1__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43--


--0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: image/gif;
	name="pic07453.gif"
Content-Disposition: inline; filename="pic07453.gif"
Content-ID: <2__=08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <3__=08BBF8F2DFE6BB438f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBF8F2DFE6BB438f9e8a93df938690918c08BBF8F2DFE6BB43--



--===============1718391016==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1718391016==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1718391016==--
