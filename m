From: "dean hildebrand" <seattleplus@gmail.com>
Subject: Re: nfs performance problem
Date: Fri, 26 Oct 2007 18:35:56 -0700
Message-ID: <c5befdd30710261835q50d34026h4dad32090db8a084@mail.gmail.com>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
	<EXNANE018awYFDIfWb400000807@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Schuldei <andreas@schuldei.org>,
	nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ilaae-0002IA-2i
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 18:35:52 -0700
Received: from wa-out-1112.google.com ([209.85.146.180])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ilaaj-0003jU-Gg
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 18:35:57 -0700
Received: by wa-out-1112.google.com with SMTP id k22so1345927waf
	for <nfs@lists.sourceforge.net>; Fri, 26 Oct 2007 18:35:56 -0700 (PDT)
In-Reply-To: <EXNANE018awYFDIfWb400000807@exnane01.hq.netapp.com>
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

>... You might consider moving it forward to 2.6.23,
> as there is a significant readahead improvement/fix there.
>...
> Fengguang Wu's changes are merged in 2.6.23,
>...Tom,

Improving out-of-order nfsd requests is a great idea.  Is there a
description of Fengguang Wu's improvements or maybe a link to the
specific patches. I tried searching through git and such and not sure
if I found the right set of patches.

Dean


>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
