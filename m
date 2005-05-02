From: "Steven A. Falco" <sfalco@aastra.com>
Subject: FC3 server -> Solaris client, directories come and go
Date: Mon, 02 May 2005 13:40:58 -0400
Message-ID: <4276662A.5050602@aastra.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------080609050509090405080705"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSeur-0007yZ-5r
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 10:41:09 -0700
Received: from mail.aastra.com ([216.94.98.95] helo=mailfrnt.aastra.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DSeun-0001ow-R6
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 10:41:09 -0700
To: NFS List <nfs@lists.sourceforge.net>
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

This is a multi-part message in MIME format.
--------------080609050509090405080705
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I'm having a problem with directories "disappearing" using a Fedora 3 
NFS server and a solaris 5.10 client (NFS v3).  When I first cd into the 
directory, an ls shows what I expect.  If I then wait an hour and redo 
the ls, I get:

    .: No such file or directory

If I then do a pwd, followed by another ls, the diretory contents 
reappear.  For example:

    solara$ ls
    .: No such file or directory
    solara$ pwd
    /proj/videorunner/hw/vr_enc/cae/PLD/lbenc/src
    solara$ ls
    AUDX_NEW/                  mt48lc8m16a2_.vhd
    FLYWHEEL_DEC/              outdata0.txt

I captured the NFS traffic with ethereal.  When I do the initial ls, the 
sequence is a series of LOOKUP calls (walking the pathname) followed by 
a READDIRPLUS call to obtain the file names.

When I later do the ls, an ACCESS call is issued, and that call returns 
ERR_NOENT.  This is the first ACCESS call that I see in the trace.  
After the pwd, when the ls works, I instead see a series of LOOKUPs that 
again traverses the pathname, followed by LOOKUPs for all the filenames 
in the directory (so obviously the directory contents were cached in the 
solaris machine).  So apparently, the ACCESS calls fail, but they are 
only issued by solaris in certain circumstances, in this case when doing 
an ls in a window that has been idle for an hour.

Curiously, all the permissions in the directories of the pathname 
include world read/execute, so I don't understand why the ACCESS call 
would return ERR_NOENT.  Also, if there were a permissions problem, I 
would expect that to show up during the initial cd into the directory.

I have not found anything like this in the archives.  Has anyone else 
seen this, and if so, are there any fixes/workarounds?  I can post all 
or part of the ethereal traces if that would help.

    Steve Falco


--------------080609050509090405080705
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
<tt>I'm having a problem with directories "disappearing" using a Fedora
3 NFS server and a solaris 5.10 client (NFS v3).&nbsp; When I first cd into
the directory, an ls shows what I expect.&nbsp; If I then wait an hour and
redo the ls, I get:<br>
<br>
&nbsp;&nbsp;&nbsp; .: No such file or directory<br>
<br>
If I then do a pwd, followed by another ls, the diretory contents
reappear.&nbsp; For example:<br>
</tt>
<blockquote><tt>solara$ ls</tt><br>
  <tt>.: No such file or directory</tt><br>
  <tt>solara$ pwd</tt><br>
  <tt>/proj/videorunner/hw/vr_enc/cae/PLD/lbenc/src</tt><br>
  <tt>solara$ ls</tt><br>
  <tt>AUDX_NEW/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mt48lc8m16a2_.vhd</tt><br>
  <tt>FLYWHEEL_DEC/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; outdata0.txt</tt><br>
</blockquote>
<tt>I captured the NFS traffic with ethereal.&nbsp; When I do the initial
ls, the sequence is a series of LOOKUP calls (walking the pathname)
followed by a READDIRPLUS call to obtain the file names.<br>
<br>
When I later do the ls, an ACCESS call is issued, and that call returns
ERR_NOENT.&nbsp; This is the first ACCESS call that I see in the trace.&nbsp;
After the pwd, when the ls works, I instead see a series of LOOKUPs
that again traverses the pathname, followed by LOOKUPs for all the
filenames in the directory (so obviously the directory contents were
cached in the solaris machine).&nbsp; So apparently, the ACCESS calls fail,
but they are only issued by solaris in certain circumstances, in this
case when doing an ls in a window that has been idle for an hour.<br>
<br>
Curiously, all the permissions in the directories of the pathname
include world read/execute, so I don't understand why the ACCESS call
would return ERR_NOENT.&nbsp; Also, if there were a permissions problem, I
would expect that to show up during the initial cd into the directory.<br>
<br>
I have not found anything like this in the archives.&nbsp; Has anyone else
seen this, and if so, are there any fixes/workarounds?&nbsp; I can post all
or part of the ethereal traces if that would help.<br>
<br>
&nbsp;&nbsp;&nbsp; Steve Falco<br>
<br>
</tt>
</body>
</html>

--------------080609050509090405080705--


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
