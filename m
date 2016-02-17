Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43636 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424233AbcBQWwW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 17:52:22 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: "Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1 Session Trunking"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
Date: Wed, 17 Feb 2016 17:52:03 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Martin Houry <martinhoury@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <B748F703-4298-4D1D-BACB-13B0560E5901@oracle.com>
References: <CAEUt8V+L3hV1tQTzanVjGyZ1qoG8qJk7ZnS5HM1_3+Nc4mpO3A@mail.gmail.com> <F6DC5176-6340-4945-9EBD-537410882E1D@netapp.com> <B10307D6-13C6-4A04-B3A9-B66C27F51E19@oracle.com> <20160217205929.GF10401@fieldses.org> <3B48A59F-638A-45C9-B2E4-2D65C00DE639@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 17, 2016, at 5:35 PM, Adamson, Andy <William.Adamson@netapp.com> wrote:
> 
> 
>> On Feb 17, 2016, at 3:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>> On Wed, Feb 17, 2016 at 02:06:35PM -0500, Chuck Lever wrote:
>>> 
>>>> On Feb 17, 2016, at 9:50 AM, Adamson, Andy
>>>> <William.Adamson@netapp.com> wrote: Thanks for testing. As Trond
>>>> pointed out, the correct way to indicate multiple hostnames is on
>>>> the mount command line
>>>> 
>>>> mount -o minorversion=1 host1,host2,ÃĒâŽÂĶ,hostn:/<export>  /<mntdir>
>>> 
>>> It might be more natural for NFSv4.x to use a referral or a pNFS
>>> layout instead.  Do you think that's a viable approach?
>> 
>> Seems like an easy application for fs_locations{_info?}.  It'd need
>> server support too, and I think you probably want this manual method as
>> well for now.
> 
> I agree that the manual method is useful as it allows the client admin to decide if the mount requires session trunking.

Seems like the server admin is in a better position to know
the locations of replicated data. The server can advertise
the most up-to-date location information. More scalable
than telling every client admin how to set this up.

Adding this CLI to mount means it will be around a long time,
so we'd better be sure we want to support it for that long.
(Yes, I know, who is this "we").


> The fs_locations would need to be requested by the client. I guess we reqest them at every mountâĶ.

Yep, and fetch them again every so often. There's no real
cache coherency protocol for this information. (That's
where a pNFS layout might be more valuable).

The Linux server should be able to advertise replicas using
the replicas= export option.


>> I wonder if the server can easily generate a list of IP addresses to
>> advertise automatically?  
> 
> Yes - fs_locations!
> 
> â>Andy
> 
>> In which case the whole thing would be
>> zero-configuration, which would be nice.
>> 
>> pNFS sounds like overkill.
>> 
>> --b.
> 
> N§ēæėrļyúčØbēXŽķĮ§vØ^)Þš{.nĮ+·Ĩ{ąû"Ø^nrĄöĶzËëhĻč­Ú&ĒøŪGŦéhŪ(­éÝĒj"úķm§ĸïęäzđÞāþfĢĒ·h§~m

--
Chuck Lever




