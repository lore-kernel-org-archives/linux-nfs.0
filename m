From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Wed, 29 Apr 2009 11:45:43 +1000
Message-ID: <ac442c870904281845p44ae54een89aaff8781deea53@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202938.939647000@sgi.com>
	 <20090425215745.GA5088@fieldses.org>
	 <20090425220329.GB5088@fieldses.org>
	 <A11EACD6-B05E-4A1A-A38C-F65B2DFB77B3@oracle.com>
	 <20090427232225.GB5108@fieldses.org>
	 <4993A7C8-342E-47BE-997A-AF18E5DF41BE@oracle.com>
	 <20090428155736.GH17891@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:14485 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbZD2Bpo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 21:45:44 -0400
Received: by qw-out-2122.google.com with SMTP id 5so805292qwd.37
        for <linux-nfs@vger.kernel.org>; Tue, 28 Apr 2009 18:45:43 -0700 (PDT)
In-Reply-To: <20090428155736.GH17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2009 at 1:57 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Apr 28, 2009 at 11:37:09AM -0400, Chuck Lever wrote:
>>
>> (Responding a bit to Greg) IMO highlighting the differences instead
>> means a person trying to understand this interface has to read the whole
>> damn nfsctl.c file instead of looking at the one piece s/he is
>> interested in.  This is documentation, not code, so I think a little
>> text duplication is OK or even actually preferred.
>
> Agreed, and I agree that nobody should have to read the whole file.  But
> appropriate cross-references ("foo() behaves like bar() except...")
> could prevent that.

I think that would be a definite improvement.  I'll see what I can do.

-- 
Greg.
