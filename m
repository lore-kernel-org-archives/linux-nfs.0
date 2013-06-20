Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:40232 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757829Ab3FTO4m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jun 2013 10:56:42 -0400
Message-ID: <51C3181F.5010607@mellanox.com>
Date: Thu, 20 Jun 2013 17:56:31 +0300
From: Or Gerlitz <ogerlitz@mellanox.com>
MIME-Version: 1.0
To: Wendy Cheng <s.wendy.cheng@gmail.com>
CC: Devesh Sharma <devesh28@gmail.com>, Tom Tucker <tom@opengridcomputing.com>,
        Yan Burman <yanb@mellanox.com>, Tom Talpey <tom@talpey.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com> <20130428144248.GA2037@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9C90C@MTLDAG01.mtl.com> <517FD327.3060901@talpey.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9CBD0@MTLDAG01.mtl.com> <5180145A.5030305@opengridcomputing.com> <CALsNU1MsjH5=p4Wtj2aJ5+odC7y7-5oTGhrzOL-=15pXaYYUZw@mail.gmail.com> <CABgxfbFhZTBO81WC5BcRRfQB_YBjE4N=sfS+G9eAzaFHYC_dWw@mail.gmail.com>
In-Reply-To: <CABgxfbFhZTBO81WC5BcRRfQB_YBjE4N=sfS+G9eAzaFHYC_dWw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19/06/2013 18:47, Wendy Cheng wrote:
> what kind of HW I would need to run it ?

The mlx4 driver supports memory windows as of kernel 3.9

Or.
