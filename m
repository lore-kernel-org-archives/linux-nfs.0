From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/7] nfsstat: add has_stats()
Date: Wed, 1 Aug 2007 08:12:44 +1000
Message-ID: <18095.46044.158241.412513@notabene.brown>
References: <Pine.BSO.4.64.0707311707400.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzxV-0004ez-9B
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 15:12:53 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzxY-0001Cz-01
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 15:12:57 -0700
In-Reply-To: message from david m. richter on Tuesday July 31
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

On Tuesday July 31, richterd@citi.umich.edu wrote:
> 	To help readability, add has_stats() and use it when deciding 
> whether to print.
.....
> +
> +static int
> +has_stats(const unsigned int *info)
> +{
> +	return (info[0] && info[info[0] + 1] != info[0]);
> +}

To help readability even more, could you provide a comment explaining
what this function is really testing.  I can almost see it, but a
comment would help a lot!

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
