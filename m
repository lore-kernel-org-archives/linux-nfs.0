Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34750 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933161Ab2FGWGB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 18:06:01 -0400
Message-ID: <4FD125B2.7030006@panasas.com>
Date: Fri, 8 Jun 2012 01:05:38 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Namjae Jeon <linkinjeon@gmail.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?UTF-8?B?4oCTIFVtb3VudCByZXN1bHRzIGluIEQ=?=
 =?UTF-8?B?ZXZpY2UgQnVzeS4=?=
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com> <4FD06290.7050004@panasas.com> <20120607113358.GB8684@fieldses.org> <4FD1242E.1010909@panasas.com>
In-Reply-To: <4FD1242E.1010909@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2012 12:59 AM, Boaz Harrosh wrote:
<>

> 
>> If you're just looking for a command you could run on the server after
>> all the clients have unmounted--"exportfs -f" 


BTW: just that one does the trick, thanks learn something new

>> or "service stop nfsd" (or equivalent) should do the job.
>>


That's the one I used to do manually because of the wrong shut down
order in Fedora.

Thanks
Boaz
