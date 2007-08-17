From: "Ignatius Pradeep Kumar Joseph" <IgnatiusPradeep_Joseph@mindtree.com>
Subject: StreamCorruptedException Urgent.
Date: Fri, 17 Aug 2007 18:46:39 +0530
Message-ID: <9AE21525342E4C4F8ECDC61B978843BD03823274@mtw01ex02.mindtree.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0257021990=="
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM1hl-0002Cd-6o
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 06:17:33 -0700
Received: from [203.200.60.136] (helo=mailwo11.mindtree.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IM1hm-0004OR-67
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 06:17:37 -0700
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

This is a multi-part message in MIME format.

--===============0257021990==
Content-Transfer-Encoding: 7bit
Content-Class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C7E0D0.D855B826"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7E0D0.D855B826
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi,

=20

We are facing the following issue "StreamCorruptedException", when we =
are
writing large files into NFS directory. The report we were trying to run =
was
of 41MB size.=20

When we un-mount the NFS and write the large file directly to the =
application
server directly, we don't face any issues. For the moment, in order to =
make
the CAT successful, we have un-mounted the NFS in QA2 and set up the =
same in
QA3 where the stack is deployed.=20

=20

But we have to test these reports with the NFS before we can release it =
to
other environments. Please help us in finding why this issue is only
happening when we are using NFS.

=20

See below part of the stack trace. From our end we are also looking at
various forums to resolve this issue.=20

=20

2007-06-20 01:00:03,773 [service_SessionDataService-1.0] INFO
[platform.session.PlatformSessionHelper]  - end : =
invokeAppSessionServices()=20

2007-06-20 01:02:13,925 [service_ReportGeneratorService-1.0] ERROR
[common.helper.Timer]  - Report Staticstics:Total time taken to fill the
report is  :2.7473166 mins: :: 164839.0 millies=20

2007-06-20 01:02:13,925 [service_ReportGeneratorService-1.0] ERROR
[jasper.printer.PDFReportPrinter]  - After invoking
JasperFillManager.fillReport

2007-06-20 01:02:13,926 [service_ReportGeneratorService-1.0] ERROR
[jasper.printer.PDFReportPrinter]  - Before invoking =
exporter.exportReport()

2007-06-20 01:02:19,589 [service_ReportGeneratorService-1.0] ERROR
[engine.fill.JRAbstractLRUVirtualizer]  - Error devirtualizing object

java.io.StreamCorruptedException: invalid stream header

            at
java.io.ObjectInputStream.readStreamHeader(ObjectInputStream.java:737)

            at =
java.io.ObjectInputStream.<init>(ObjectInputStream.java:253)

            at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.readData(JRAbst=
ract
LRUVirtualizer.java:510)

            at
net.sf.jasperreports.engine.fill.JRSwapFileVirtualizer.pageIn(JRSwapFileV=
irtu
alizer.java:112)

            at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.requestData(JRA=
bstr
actLRUVirtualizer.java:401)

            at
net.sf.jasperreports.engine.base.JRVirtualPrintPage.ensureVirtualData(JRV=
irtu
alPrintPage.java:312)

            at
net.sf.jasperreports.engine.base.JRVirtualPrintPage.getElements(JRVirtual=
Prin
tPage.java:304)

            at
net.sf.jasperreports.engine.export.JRPdfExporter.exportPage(JRPdfExporter=
.jav
a:553)

=20

Appreciate your help.

=20

Regards,

Pradeep.

=20



DISCLAIMER:
This message (including attachment if any) is confidential and may be =
privileged. Before opening attachments please check them for viruses and =
defects. MindTree Consulting Limited (MindTree) will not be responsible =
for any viruses or defects or any forwarded attachments emanating either =
from within MindTree or outside. If you have received this message by =
mistake please notify the sender by return  e-mail and delete this =
message from your system. Any unauthorized use or dissemination of this =
message in whole or in part is strictly prohibited.Please note that =
e-mails are susceptible to change and MindTree shall not be liable for =
any improper, untimely or incomplete transmission.
E-mail may contain viruses. Before opening attachments please check them =
for viruses and defects. While MindTree Consulting Limited (MindTree) =
has put in place checks to minimize the risks, MindTree will not be =
responsible for any viruses or defects or any forwarded attachments =
emanating either from within MindTree or outside.=20

------_=_NextPart_001_01C7E0D0.D855B826
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D3 color=3Dblack face=3D"Times New =
Roman"><span
style=3D'font-size:12.0pt;color:black'>Hi,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D3 color=3Dblack face=3D"Times New =
Roman"><span
style=3D'font-size:12.0pt;color:black'><o:p>&nbsp;</o:p></span></font></p=
>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>We are facing the following issue
&#8220;StreamCorruptedException&#8221;, when we are writing large files =
into <b><span
style=3D'font-weight:bold'>NFS</span></b> directory. The report we were =
trying to
run was of 41MB size. </span></font><font color=3Dblack><span =
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>When we un-mount the NFS and write =
the
large file directly to the application server directly, we don&#8217;t =
face any
issues. For the moment, in order to make the CAT successful, we have =
un-mounted
the NFS in QA2 and set up the same in QA3 where the stack is deployed. =
</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;</span></font><font =
color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>But we have to test these reports =
with
the NFS before we can release it to other environments. Please help us =
in
finding why this issue is only happening when we are using =
NFS.</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;</span></font><font =
color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>See below part of the stack trace. =
From
our end we are also looking at various forums to resolve this issue. =
</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;</span></font><font =
color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>2007-06-20 01:00:03,773
[service_SessionDataService-1.0] INFO
[platform.session.PlatformSessionHelper]&nbsp; - end :
invokeAppSessionServices() </span></font><font color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>2007-06-20 01:02:13,925
[service_ReportGeneratorService-1.0] ERROR [common.helper.Timer]&nbsp; - =
Report
Staticstics:Total time taken to fill the report is&nbsp; :2.7473166 =
mins: ::
164839.0 millies </span></font><font color=3Dblack><span =
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>2007-06-20 01:02:13,925 =
[service_ReportGeneratorService-1.0]
ERROR [jasper.printer.PDFReportPrinter]&nbsp; - After invoking
JasperFillManager.fillReport</span></font><font color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>2007-06-20 01:02:13,926
[service_ReportGeneratorService-1.0] ERROR
[jasper.printer.PDFReportPrinter]&nbsp; - Before invoking =
exporter.exportReport()</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>2007-06-20 01:02:19,589
[service_ReportGeneratorService-1.0] ERROR
[engine.fill.JRAbstractLRUVirtualizer]&nbsp; - Error devirtualizing =
object</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>java.io.StreamCorruptedException: =
invalid
stream header</span></font><font color=3Dblack><span =
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at =
java.io.ObjectInputStream.readStreamHeader(ObjectInputStream.java:737)</s=
pan></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at =
java.io.ObjectInputStream.&lt;init&gt;(ObjectInputStream.java:253)</span>=
</font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.readData(JRAbst=
ractLRUVirtualizer.java:510)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at =
net.sf.jasperreports.engine.fill.JRSwapFileVirtualizer.pageIn(JRSwapFileV=
irtualizer.java:112)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at
net.sf.jasperreports.engine.fill.JRAbstractLRUVirtualizer.requestData(JRA=
bstractLRUVirtualizer.java:401)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at =
net.sf.jasperreports.engine.base.JRVirtualPrintPage.ensureVirtualData(JRV=
irtualPrintPage.java:312)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at
net.sf.jasperreports.engine.base.JRVirtualPrintPage.getElements(JRVirtual=
PrintPage.java:304)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
at =
net.sf.jasperreports.engine.export.JRPdfExporter.exportPage(JRPdfExporter=
.java:553)</span></font><font
color=3Dblack><span style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>&nbsp;</span></font><font =
color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>Appreciate your =
help.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'><o:p>&nbsp;</o:p></span></font></p>=


<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>Regards,<o:p></o:p></span></font></=
p>

<p class=3DMsoNormal><font size=3D2 color=3Dblack face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:black'>Pradeep.</span></font><font =
color=3Dblack><span
style=3D'color:black'><o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 face=3DArial><span =
style=3D'font-size:10.0pt;
font-family:Arial'><o:p>&nbsp;</o:p></span></font></p>

</div>

<p></p><p><b>DISCLAIMER:</b><br><br>This message (including attachment =
if any) is confidential and may be privileged. If you have received this =
message by mistake please notify the sender by return e-mail and delete =
this message from your system. Any unauthorized use or dissemination of =
this message in whole or in part is strictly prohibited.</p><p>E-mail =
may contain viruses. Before opening attachments please check them for =
viruses and defects. While MindTree Consulting Limited (MindTree) has =
put in place checks to minimize the risks, MindTree will not be =
responsible for any viruses or defects or any forwarded attachments =
emanating either from within MindTree or outside.</p> <p>Please note =
that e-mails are susceptible to change and MindTree shall not be liable =
for any improper, untimely or incomplete transmission.</p> <p>MindTree =
reserves the right to monitor and review the content of all messages =
sent to or from MindTree e-mail address. Messages sent to or from this =
e-mail address may be stored on the MindTree e-mail system or else =
where.</p></body>

</html>

------_=_NextPart_001_01C7E0D0.D855B826--


--===============0257021990==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0257021990==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0257021990==--
