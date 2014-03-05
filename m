Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:40643 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbaCEUlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 15:41:31 -0500
Date: Wed, 5 Mar 2014 14:41:28 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <20140305201149.GA16212@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com> <20140305201149.GA16212@umich.edu>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Jim Rees" <rees@umich.edu>
> To: "Andrew Martin" <amartin@xes-inc.com>
> Cc: linux-nfs@vger.kernel.org
> Sent: Wednesday, March 5, 2014 2:11:49 PM
> Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
> 
> I prefer hard,intr which lets you interrupt the hung process.
> 
Isn't intr/nointr deprecated (since kernel 2.6.25)?
