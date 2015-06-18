Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sperry-03.control.lth.se ([130.235.83.190]:37223 "EHLO
	sperry-03.control.lth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbbFRM2X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 08:28:23 -0400
Message-ID: <5582B960.7000301@control.lth.se>
Date: Thu, 18 Jun 2015 14:28:16 +0200
From: Anders Blomdell <anders.blomdell@control.lth.se>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
References: <55827B8D.3070103@control.lth.se> <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
In-Reply-To: <CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2015-06-18 13:49, Trond Myklebust wrote:
> On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
> <anders.blomdell@control.lth.se> wrote:
>>
>> I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
>> due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
>> https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
> 
> 
> Why should we change the clients if the server is in clear and obvious
> violation of the spec?
In order to make clients work with servers that worked well with previous versions
of nfs-utils, the cultprit probably being commit f9802988 that bumped the default
autonegotion version to 4.2, what the patch does is only to negotiate a lower version
in case of errors, and hence making 1.3.2 working with servers that worked with
1.3.1 (that only tried version 4[.0]).

Will probably save some people some time.

/Anders

-- 
Anders Blomdell                  Email: anders.blomdell@control.lth.se
Department of Automatic Control
Lund University                  Phone:    +46 46 222 4625
P.O. Box 118                     Fax:      +46 46 138118
SE-221 00 Lund, Sweden

