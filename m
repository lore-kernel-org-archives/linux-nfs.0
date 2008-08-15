From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: Massive NFS problems on large cluster with large number of mounts
Date: Fri, 15 Aug 2008 17:39:35 -0400
Message-ID: <76bd70e30808151439y3470245ds3093956608561dac@mail.gmail.com>
References: <20080701182250.GB21807@fieldses.org>
	 <20080717144852.GA11759@fieldses.org>
	 <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com>
	 <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com>
	 <20080730175308.GH12364@fieldses.org>
	 <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com>
	 <76bd70e30807301501p5c0ba3c6i38fee02a1e606e31@mail.gmail.com>
	 <76bd70e30808151334i19822280j67a08b92b17582ba@mail.gmail.com>
	 <1218833230.7037.29.camel@localhost>
	 <1218834252.7037.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Carsten Aulbert" <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	"Henning Fehrmann" <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	"Steffen Grunewald" <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:60157 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbYHOVjh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2008 17:39:37 -0400
Received: by gv-out-0910.google.com with SMTP id e6so498210gvc.37
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2008 14:39:36 -0700 (PDT)
In-Reply-To: <1218834252.7037.31.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 15, 2008 at 5:04 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2008-08-15 at 16:47 -0400, Trond Myklebust wrote:
>> On Fri, 2008-08-15 at 16:34 -0400, Chuck Lever wrote:
>> > Trond, NFS_MOUNT_FLAGMASK is used in nfs_init_server() and
>> > nfs4_init_server() for both legacy binary and text-based mounts.  This
>> > needs to be moved to a legacy-only path if we want to use the
>> > high-order 16 bits in the 'flags' field for text-based mounts.
>>
>> We definitely want to do this. The point of introducing text-based
>> mounts was to allow us to add functionality without having to worry
>> about legacy binary mount formats. The mask should be there in order to
>> ensure that binary formats don't start enabling features that they
>> cannot support. There is no justification for applying it to the text
>> mount path.
>
> I've attached the patch...

Thanks!

-- 
"Officer. Ma'am. Squeaker."
  -- Mr. Incredible
