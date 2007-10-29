From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs performance problem
Date: Mon, 29 Oct 2007 08:59:53 -0400
Message-ID: <EXNANE01sCRBHZXFZ0s00000820@exnane01.hq.netapp.com>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
	<EXNANE018awYFDIfWb400000807@exnane01.hq.netapp.com>
	<c5befdd30710261835q50d34026h4dad32090db8a084@mail.gmail.com> <c5befdd30710261835q50d34026h4dad32090db8a084@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "dean hildebrand" <seattleplus@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImUEm-0003zW-FI
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 06:01:01 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImUEq-0003MS-VY
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 06:01:06 -0700
In-Reply-To: <c5befdd30710261835q50d34026h4dad32090db8a084@mail.gmail.co
 m>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
	<EXNANE018awYFDIfWb400000807@exnane01.hq.netapp.com>
	<c5befdd30710261835q50d34026h4dad32090db8a084@mail.gmail.com>
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

At 09:35 PM 10/26/2007, dean hildebrand wrote:
>>... You might consider moving it forward to 2.6.23,
>> as there is a significant readahead improvement/fix there.
>>...
>> Fengguang Wu's changes are merged in 2.6.23,
>>...Tom,
>
>Improving out-of-order nfsd requests is a great idea.  Is there a
>description of Fengguang Wu's improvements or maybe a link to the
>specific patches. I tried searching through git and such and not sure
>if I found the right set of patches.

There are quite a few of them. A big one with lots of background info
is in mm/readahead.c, commit 122a21d11cbfda6d1e33cbc8ae9e4c4ee2f1886e

Check out the "readahead thrashing" results at the end of the log, especially
the comment "the more overall read density, the more possible gain", i.e. it's
the density and not the actual order which now drives the readahead.
Good stuff.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
