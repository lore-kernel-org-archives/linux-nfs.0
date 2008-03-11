From: "bc Wong" <bcwalrus@gmail.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Tue, 11 Mar 2008 11:28:29 -0800
Message-ID: <f88853200803111228s280cb748s2ab6a62af054838@mail.gmail.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>
	 <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com>
	 <f88853200803071011j3a70b0abka9142396d3275b10@mail.gmail.com>
	 <47D18983.4080507@redhat.com>
	 <f88853200803071059yf523114wcabb12fdeee7b8d6@mail.gmail.com>
	 <47D19336.9010903@redhat.com>
	 <f88853200803071138n58d16ca6t4f4410d587141141@mail.gmail.com>
	 <47D1A55F.5030200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Chuck Lever" <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Peter Staubach" <staubach@redhat.com>,
	"Steve Dickson" <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:33848 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbYCKT2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 15:28:30 -0400
Received: by rv-out-0910.google.com with SMTP id k20so1544262rvb.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Mar 2008 12:28:29 -0700 (PDT)
In-Reply-To: <47D1A55F.5030200@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 7, 2008 at 12:28 PM, Peter Staubach <staubach@redhat.com> wrote:
<snip>
>  It would be good to ensure that they continue to work.
>
>     Thanx...
>
>        ps

Hi,

I tested the original patch against the Solaris AUTH_NONE server
setup. It works. Two cases specifically:
(1) share -F nfs -o sec=none <export>
(2) share -F nfs -o sec=sys:none,anon=-1 <export>

(1) works both before and after. Client uses AUTH_NONE. (2) would
cause degraded client access before (using AUTH_NONE), but works
after the patch (using AUTH_SYS).

Thanks,
bc
