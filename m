From: Abhas Abhinav <abhas@deeproot.co.in>
Subject: Error: RPC request reserved 244 but used 248
Date: Fri, 17 May 2002 07:01:12 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.43.0205170658200.3848-100000@anubhav.lan.deeproot.co.in>
References: <20020516153907.A23113@lucon.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [202.71.150.112] (helo=amogh.deeproot.co.in)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178Wsm-0004Z8-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 18:50:12 -0700
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
In-Reply-To: <20020516153907.A23113@lucon.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi...

I have been running nhfsstone on a tcp-mount NFS partition. Both the
client and the server are running 2.4.8. The server uses ReiserFS for
its disk partition. I've applied the respective nfs-tcp patches to the
client and server... and was able to mount the nfs export using mount
-otcp on the client...

However, during the test, the server kept giving the error:

RPC request reserved 244 but used 248

Any idea what this error could mean and how to stop it?

thanks,
Abhas.

-- 
-------------------------------------------------------------------
Abhas Abhinav		   | Free Software at its product-ive best.
CEO, DeepRoot Linux
http://www.deeproot.co.in           ---- Server Appliances ----
Ph: +91 (80) 856 5624          ---- Linux Support and Services ----
-------------------------------------------------------------------


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
