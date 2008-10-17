From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 0/3] NFSD EOS deferral
Date: Fri, 17 Oct 2008 16:26:18 -0400
Message-ID: <RTPCLUEXC1-PRDidcDj000001ca@RTPMVEXC1-PRD.hq.netapp.com>
References: <1224104426-12293-1-git-send-email-andros@netapp.com>
 <20081017174454.GB11884@fieldses.org>
 <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@us.ibm.com> <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@
 us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: Marc Eshel <eshel@almaden.ibm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61135 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbYJQUao (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 16:30:44 -0400
In-Reply-To: <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@
 us.ibm.com>
References: <1224104426-12293-1-git-send-email-andros@netapp.com>
 <20081017174454.GB11884@fieldses.org>
 <OF9E4C4BA6.37418EC7-ON882574E5.0067FB2B-882574E5.0068487F@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:59 PM 10/17/2008, Marc Eshel wrote:
>linux-nfs-owner@vger.kernel.org wrote on 10/17/2008 10:44:54 AM:
>
>> "J. Bruce Fields" <bfields@fieldses.org> 
>> Requests longer than a page are still not deferred, so large writes that
>> trigger upcalls still get an ERR_DELAY.  OK, probably no big deal.
>> 
>> I don't think we can apply this until we have some way to track the
>> number and size of deferred requests outstanding and fall back on
>> ERR_DELAY if it's too much.
>
>But I thought that the problem here is that the Linux NFS client doesn't 
>handle this return code properly.

Definitely this is an issue. Early clients do one of two things, they either
pass the error back to the application, or they enter a buzz loop resending
the operation with no delay. Later clients back off, but for a constant
five seconds. Either way, the server is generally better off gritting its
teeth and completing the operation.

Blocking server threads is drastic, but in effect it will stall the client
queues and "push back". The issue on Linux is the small number of
nfsd contexts involved. It could lead to significant issues possibly
including DOS attack. Dropping connections (judiciously) could be
used instead of blocking the last few threads, though even that will
have consequences.

The easy way to test all this is decorate /etc/exports with lots of
names, then break the nameservice and start sending requests from
many new clients. It's very hard to get it all right.

Tom.

