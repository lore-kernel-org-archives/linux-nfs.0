Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:17349 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaGJTHp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 15:07:45 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for NFSv2/3
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140710184948.GC26561@fieldses.org>
Date: Thu, 10 Jul 2014 15:07:34 -0400
Cc: swise@ogc.net, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Message-Id: <B89AB7AC-32E1-4944-9287-73958A569A8E@oracle.com>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net> <20140710174435.3734.69638.stgit@klimt.1015granger.net> <20140710181944.GB26561@fieldses.org> <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com> <20140710184948.GC26561@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Jul 10, 2014, at 2:49 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Thu, Jul 10, 2014 at 02:24:57PM -0400, Chuck Lever wrote:
>> 
>> On Jul 10, 2014, at 2:19 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> On Thu, Jul 10, 2014 at 01:44:35PM -0400, Chuck Lever wrote:
>>>> The server should comply with RFC 5667,
>>> 
>>> Where's the relevant language?  (I took a quick look but didn't see it.)
>> 
>> Sorry, I listed the wrong RFC when I wrote the description of bug 246.
>> It’s actually RFC 5666, section 3.7.
> 
> Thanks.
> 
>>> So I think you just want to drop the round-up of len, not the whole
>>> check.
>> 
>> I’ll try that, thanks!

Works-as-expected.

> Actually, I'd really rather this get fixed up in the rpc layer.  The
> padding is really required for correct xdr.

How so? All of NFSv4 and all other NFSv3 operations work as expected
without that padding present. There doesn’t seem to be any operational
dependency on the presence of padding. Help?

> The fact that RDMA doesn't
> require those zeroes to be literally transmitted across the network
> sounds like a transport-level detail that should be hidden from the xdr
> code.

The best I can think of is adding a false page array entry to the
xdr_buf if the last incoming page is short by a few bytes.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



