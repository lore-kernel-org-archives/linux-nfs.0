Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55711 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2FKM2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jun 2012 08:28:05 -0400
Date: Mon, 11 Jun 2012 08:28:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?utf-8?B?4oCTIFVt?=
	=?utf-8?Q?ount?= results in Device Busy.
Message-ID: <20120611122800.GE7654@fieldses.org>
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com>
 <4FD06290.7050004@panasas.com>
 <20120607113358.GB8684@fieldses.org>
 <4FD1242E.1010909@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FD1242E.1010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 08, 2012 at 12:59:10AM +0300, Boaz Harrosh wrote:
> On 06/07/2012 02:33 PM, J. Bruce Fields wrote:
> 
> > On Thu, Jun 07, 2012 at 11:13:04AM +0300, Boaz Harrosh wrote:
> 
> 
> > 
> > I'm not sure how adding an "unmount" rpc to the protocol would really
> > help here, if that's what you're asking for.
> > 
> 
> 
> Please elaborate a bit. I'm not familiar with the details of this
> discussion.

The mount protocol used with NFSv2/v3, for example, has mount/unmount
calls, and I seem to recall problems with keeping the list of mounted
clients accurate in the face of unreliable clients and networks.

I guess you could add the same but make them subject to the lease, so a
client would be assumed "unmounted" if it lost its lease.  I don't know.

But the reported problems here sound like just simple bugs, so I'm not
interested in such discussion till the bugs are investigated and fixed
and someone explains what problem then remains to be solved.

--b.
