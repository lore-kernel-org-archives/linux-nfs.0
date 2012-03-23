Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:57652 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758153Ab2CWLtR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 07:49:17 -0400
Date: Fri, 23 Mar 2012 07:49:13 -0400
From: Jim Rees <rees@umich.edu>
To: Vivek Trivedi <vtrivedi018@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <linkinjeon@gmail.com>,
        amit.sahrawat83@gmail.com
Subject: Re: NFS: low read/stat performance on small files
Message-ID: <20120323114913.GB24489@umich.edu>
References: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKX=r8A90b25VKXC1qtAota9DqDrj37xFT511DuvrZ=1Eux6Xw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Vivek Trivedi wrote:

  204800 bytes (200.0KB) copied, 0.027074 seconds, 7.2MB/s
  Read speed for 200KB file is 7.2 MB

  104857600 bytes (100.0MB) copied, 9.351221 seconds, 10.7MB/s
  Read speed for 100MB file is 10.7 MB
  
  As you see read speed for 200KB file is only 7.2MB/sec while it is
  10.7 MB/sec when we read 100MB file.
  Why there is so much difference in read performance ?
  Is there any way to achieve high read speed for small files ?

That seems excellent to me.  204800 bytes at 11213252 per sec would be 18.2
msec, so your per-file overhead is around 9 msec.  The disk latency alone
would normally be more than that.
