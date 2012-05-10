Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43031 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756492Ab2EJMQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 08:16:23 -0400
Date: Thu, 10 May 2012 08:16:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: AMIT SAHRAWAT <a.sahrawat@samsung.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: Re: [Problem]NFS Server =?utf-8?B?4oCT?=
	=?utf-8?Q?_Um=3Fount?= results in Device Busy.
Message-ID: <20120510121621.GA2260@fieldses.org>
References: <0M3T007GD2F8JJX0@mailout4.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0M3T007GD2F8JJX0@mailout4.samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2012 at 11:54:43AM +0000, AMIT SAHRAWAT wrote:
> </head><body>
> <p>Hi Bruce,</p>
> <p>&nbsp;</p>
> <p>Thanks for instant reply.</p>

Could you turn off html formatting on your mail?

> <p>The option you mentioned is working. 'exportfs -f'</p>
> <p>Actually it is not mentioned anywhere - even when checked for options:</p>
> <p>#&gt; exportfs -h<br>exportfs: invalid option -- 'h'<br>usage: exportfs [-aruv] [host:/path]<br></p>

Sorry, it looks like the help test could be improved!  Patches
welcomed....

It is documented in the exportfs man page.

> <p>But - when tried to give - '-f' option it is working.</p>
> <p>Then on checking the code for exportfs - got to know the working of '-f' option.</p>
> <p>I think it should work. I will check with a number of scenario&nbsp; - to check there is no blockage for other mount points - at the time 'exportfs -f' is being run. Please reply if it wont :)</p>

If no clients are using the export, it should work.

--b.
