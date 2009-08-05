From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] new statd [take 2]
Date: Wed, 5 Aug 2009 14:06:39 -0400
Message-ID: <9ACB8AA1-8442-4313-9494-DE78F49FE826@oracle.com>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805131554.67eb15bc@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:61506 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbZHESG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 14:06:59 -0400
In-Reply-To: <20090805131554.67eb15bc-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 5, 2009, at 1:15 PM, Jeff Layton wrote:
> On Wed, 05 Aug 2009 10:45:30 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> Apparently there is a 100KB per-email size limit imposed by
>> vger.kernel.org.  I've broken up the large statd patch, and
>> postponed the nfs(8) man page patches to another day.
>>
>> Yesterday it was decided that:
>>
>>  [PATCH 3/5] statd: change default state dir to /var/lib/nfs/statd
>>
>> was overkill. That one has been dropped from this series.
>>
>> The first two of the present patches introduce the .c files under
>> utils/new-statd/ .  The next patch adds actools infrastructure for
>> building the new statd and sm-notify executables.  The last patch
>> adds two new man pages for statd and sm-notify.
>>
>> The old statd remains in utils/statd.  If sqlite3 and TI-RPC is
>> present on the build system, and TI-RPC is enabled during
>> configuration, the new statd is built and installed instead of the
>> old one.
>>
>> See the description in the first patch for more details on the
>> features of the new implementation.
>>
>
> Nice work, Chuck.
>
> Rewriting statd from scratch is a pretty bold step, but I think it's
> warranted.
>
> I've been testing this new implementation over several iterations and
> the recent ones have worked well for me so far. I've also walked
> through the code and it all seems to make sense.
>
> Acked-by: Jeff Layton <jlayton@redhat.com>

Independent testing was an important piece of this work.  Thanks to  
Jeff and Sankar Bose at NetApp for their assistance so far.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
