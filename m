From: "Raghuram bondalapati" <bondalapati@excite.com>
Subject: syn_retries issue on NFS over TCP for  IPF
Date: Thu, 21 Oct 2004 19:34:57 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041021233457.633163D10@xprdmailfe10.nwk.excite.com>
Reply-To: bondalapati@excite.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="EXCITEBOUNDARY_000__d63cb762f35c041094fd0ba81e10fd92";
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKmSc-0005vt-18
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 16:35:10 -0700
Received: from nn7.excitenetwork.com ([207.159.120.61] helo=excite.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CKmSa-0002K7-UZ
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 16:35:09 -0700
To: nfs@lists.sourceforge.net
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




--EXCITEBOUNDARY_000__d63cb762f35c041094fd0ba81e10fd92
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 

Hi all we are running into some NFS issues based on client/server interaction across firewall on IPF (AW2.1.5) systems.

Monitoring the TCP traffic we observed that on IA32 (RedHat 7.3), client requests to a NFS filesystem mounted using TCP causes a tcp connection to be established between client and server by honoring the option tcp_syn_retries  and using exponential backoff between each retry.  The connection times out after the retries as specified by tcp_syn_retries .

For IPF this does not seem to be the case and the client tries to send SYN requests alternating between every 2 &amp; 3 seconds and does not follow the expoenential backoff between each SYN. Is there any tunable parameter that can be tweaked for IPF to behave similar to IA32.

Regards

RAM

 

_______________________________________________
Join Excite! - http://www.excite.com
The most personalized portal on the Web!

--EXCITEBOUNDARY_000__d63cb762f35c041094fd0ba81e10fd92
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 <table cellpadding=3 cellspacing=0 border=0 width=100% bgcolor=white><tr valign=top><td width=100%><font size=2 color=black><FONT size=2>

<P>Hi all we are running into some NFS issues based on client/server interaction across firewall on IPF (AW2.1.5) systems.</P>

<P>Monitoring the TCP traffic we observed that on IA32 (RedHat 7.3), client requests to a NFS filesystem mounted using TCP causes a tcp connection to be established between client and server by honoring the option <STRONG>tcp_syn_retries</STRONG>  and using exponential backoff between each retry.  The connection times out after the retries as specified by <STRONG>tcp_syn_retries</STRONG> .</P>

<P>For IPF this does not seem to be the case and the client tries to send SYN requests alternating between every 2 &amp; 3 seconds and does not follow the expoenential backoff between each SYN. Is there any tunable parameter that can be tweaked for IPF to behave similar to IA32.</P>

<P>Regards</P>

<P>RAM</P></FONT><BR><BR><BR>

<BLOCKQUOTE style="PADDING-LEFT: 7px; MARGIN-LEFT: 7px; BORDER-LEFT: orange 2px solid"> </BLOCKQUOTE><br></font></td></tr></table><p><hr><font size=2 face=geneva><b>Join Excite! - <a href=http://www.excite.com target=_blank>http://www.excite.com</a></b><br>The most personalized portal on the Web!</font>

--EXCITEBOUNDARY_000__d63cb762f35c041094fd0ba81e10fd92--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
