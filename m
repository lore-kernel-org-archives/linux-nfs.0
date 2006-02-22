From: "Chris Penney" <penney@msu.edu>
Subject: Re: Writing to an NFS share truncates files on >8Tb Raid + LVM2
Date: Wed, 22 Feb 2006 08:41:23 -0500
Message-ID: <111aefd0602220541l35019fa4me72c0227230d2c36@mail.gmail.com>
References: <43FC3ED3.2060908@vanalteren.nl>
	 <111aefd0602220459s1786fe4ewddc5c21698002e27@mail.gmail.com>
	 <43FC6252.2030104@vanalteren.nl> <43FC63F5.6090809@vanalteren.nl>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_3715_14965668.1140615683545"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBuFC-0002lJ-Mv
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:41:26 -0800
Received: from zproxy.gmail.com ([64.233.162.194])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBuFB-0003EU-Gj
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:41:26 -0800
Received: by zproxy.gmail.com with SMTP id 13so1415807nzp
        for <nfs@lists.sourceforge.net>; Wed, 22 Feb 2006 05:41:24 -0800 (PST)
To: "Ramon van Alteren" <ramon@vanalteren.nl>,
	nfs@lists.sourceforge.net
In-Reply-To: <43FC63F5.6090809@vanalteren.nl>
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

------=_Part_3715_14965668.1140615683545
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 2/22/06, Ramon van Alteren <ramon@vanalteren.nl> wrote:
>
> Ramon van Alteren wrote:
>
> > But now I need to figure out which filesystem I will use.
> > Testing reveals that ext3 is pretty fast:
> > http://linuxgazette.net/122/piszcz.html
> > However I have no clue how ext3 behaves with >8Tb filesystems.



What is the workload going to be like on your server?  In general, I don't
think you can go wrong with JFS.  If you are doing mostly reads, esp. of
smaller files, it probablly matters less, but the systems I maintain are 85=
%
writes with average file sizes around 10-20mb and range from a few bytes to
in excess of 100gb and I've found that ext3 and reiserfs3 (I was testing
with smaller file systems using the same number of luns from our san) do no=
t
perform to the same level as jfs and xfs, with jfs getting the nod for clea=
r
reliability benefits in our failure mode testing (rebooting, hba failover,
etc.).

   Chris

------=_Part_3715_14965668.1140615683545
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

<br><div><span class=3D"gmail_quote">On 2/22/06, <b class=3D"gmail_senderna=
me">Ramon van Alteren</b> &lt;<a href=3D"mailto:ramon@vanalteren.nl">ramon@=
vanalteren.nl</a>&gt; wrote:</span><blockquote class=3D"gmail_quote" style=
=3D"border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; p=
adding-left: 1ex;">
Ramon van Alteren wrote:<br><br>&gt; But now I need to figure out which fil=
esystem I will use.<br>&gt; Testing reveals that ext3 is pretty fast:<br>&g=
t; <a href=3D"http://linuxgazette.net/122/piszcz.html">http://linuxgazette.=
net/122/piszcz.html
</a><br>&gt; However I have no clue how ext3 behaves with &gt;8Tb filesyste=
ms.</blockquote><div><br><br>What is the workload going to be like on your =
server?&nbsp; In general, I don't think you can go wrong with JFS.&nbsp; If=
 you are doing mostly reads, esp. of smaller files, it probablly matters le=
ss, but the systems I maintain are 85% writes with average file sizes aroun=
d 10-20mb and range from a few bytes to in excess of 100gb and I've found t=
hat ext3 and reiserfs3 (I was testing with smaller file systems using the s=
ame number of luns from our san) do not perform to the same level as jfs an=
d xfs, with jfs getting the nod for clear reliability benefits in our failu=
re mode testing (rebooting, hba failover, etc.).
<br><br>&nbsp;&nbsp; Chris<br><br></div></div>

------=_Part_3715_14965668.1140615683545--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
