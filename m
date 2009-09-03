From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS for millions of files
Date: Thu, 3 Sep 2009 15:05:27 -0400
Message-ID: <20090903190527.GB10670@fieldses.org>
References: <20090902180841.GF946@proxime.net> <4A9EBB6B.4040009@redhat.com> <20090903181535.GA10670@fieldses.org> <4AA00CFF.6010304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	Jason Legate <linux-nfs-17UcKVrmzybR7s880joybQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Ric Wheeler <rwheeler@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756059AbZICTF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 15:05:26 -0400
In-Reply-To: <4AA00CFF.6010304@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2009 at 02:37:51PM -0400, Ric Wheeler wrote:
> On 09/03/2009 02:15 PM, J. Bruce Fields wrote:
>> On Wed, Sep 02, 2009 at 02:37:31PM -0400, Peter Staubach wrote:
>>    
>>> Please keep in mind that the NFS stable storage requirements are
>>> probably causing a significant slowdown in activities such as this.
>>>      
>> My first thought too, but:
>>
>>    
>>> Jason Legate wrote:
>>>      
>>>> When I run our creation benchmark locally  I can get around 3000
>>>> files/ second in the configuration we're using now, but only around
>>>> 300/second over NFS.  It's mounted as this:
>>>>        
>> ...
>>    
>>>> When I mount the same FS over localhost instead of across the lan,
>>>> it performs about full speed (the 3000/sec).
>>>>        
>> The localhost NFS mount would be incurring the same sync latency, so all
>> his latency must be due to network.  (And with those numbers I guess
>> he's either got lots of disk spindles, or an ssd, or (uh-oh) has the
>> async option set?)
>>
>> --b.
>>    
>
> For small files without doing an fsync per file, getting 3000 files/sec  
> is not that much. Ext3 can do it with a local s-ata disk. I suspect that  
> Jason would run much slower if he ran with local fsync()'s enabled  
> (similar to what NFS servers have to do).

Yeah, which is why I was suspecting they set "async" on the export.  In
which case I hope they know what they're doing....

--b.
