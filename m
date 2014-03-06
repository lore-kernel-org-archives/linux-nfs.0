Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:14253 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbaCFQn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 11:43:56 -0500
Date: Thu, 6 Mar 2014 10:43:42 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: Jim Rees <rees@umich.edu>
Cc: bhawley@luminex.com, NeilBrown <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-ID: <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <20140306162208.GA18207@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140306145042.6db53f60@notabene.brown> <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com> <20140306163721.0edfb498@notabene.brown> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: "Jim Rees" <rees@umich.edu>
> Andrew Martin wrote:
> 
>   > From: "Jim Rees" <rees@umich.edu>
>   > Given this is apache, I think if I were doing this I'd use
>   > ro,soft,intr,tcp
>   > and not try to write anything to nfs.
>   I was using tcp,bg,soft,intr when this problem occurred. I do not know if
>   apache was attempting to do a write or a read, but it seems that
>   tcp,soft,intr
>   was not sufficient to prevent the problem.
> 
> I had the impression from your original message that you were not using
> "soft" and were asking if it's safe to use it. Are you saying that even with
> the "soft" option the apache gets stuck forever?
Yes, even with soft, it gets stuck forever. I had been using tcp,bg,soft,intr
when the problem occurred (on several ocassions), so my original question was
if it would be safe to use a small timeo and retrans values to hopefully 
return I/O errors quickly to the application, rather than blocking forever 
(which causes the high load and inevitable reboot). It sounds like that isn't
safe, but perhaps there is another way to resolve this problem?
