Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:65382 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbaDDSQP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 14:16:15 -0400
Date: Fri, 4 Apr 2014 13:15:57 -0500 (CDT)
From: Andrew Martin <amartin@xes-inc.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, bhawley@luminex.com,
        Brown Neil <neilb@suse.de>, linux-nfs-owner@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-ID: <2145135764.439620.1396635357035.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <20140328220038.GK6041@fieldses.org>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com> <76B038DA-3E86-4C46-BFB6-928BFB8202D8@primarydata.com> <521763040.159828.1394138758307.JavaMail.zimbra@xes-inc.com> <40C20DD8-9E8D-4625-B98C-A1E61D00AC17@primarydata.com> <693414378.60415.1395179429651.JavaMail.zimbra@xes-inc.com> <A95B7939-BDEB-4FFB-BCC0-6EAD9487E7D8@primarydata.com> <20140328220038.GK6041@fieldses.org>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

----- Original Message -----
> From: "Dr Fields James Bruce" <bfields@fieldses.org>
> > Bruce, it looks like the above should have been fixed in Linux 2.6.35 with
> > commit 9045b4b9f7f3 (nfsd4: remove probe task's reference on client), is
> > that correct?
> 
> Yes, that definitely looks it would explain the bug.  And the sysrq
> trace shows 2.6.32-57.
> 
> Andrew Martin, can you confirm that the problem is no longer
> reproduceable on a kernel with that patch applied?
I have upgraded to 3.0.0-32. Since this problem is intermittent, I'm not sure
when I will be able to reproduce it (if ever), but I'll reply to this thread 
if it ever reoccur.

Thanks everyone for the help!

Andrew
