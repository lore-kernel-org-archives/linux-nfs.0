From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: problems with lockd in 2.6.22.6
Date: Fri, 7 Sep 2007 22:39:11 +0200
Message-ID: <20070907203911.GA7706@uio.no>
References: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: wolfgang.walter@studentenwerk.mhn.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITkbk-00080y-B7
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 13:39:16 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ITkbm-00044P-Nn
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 13:39:21 -0700
In-Reply-To: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de>
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

On Fri, Sep 07, 2007 at 05:49:55PM +0200, Wolfgang Walter wrote:
> 2) The number of nfsd threads we are running on the machine is 1024. So this is not
> the problem.

Wow, 1024? How many clients do you have? I'd normally assume 16 or 32 or
something was a reasonable value...

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
