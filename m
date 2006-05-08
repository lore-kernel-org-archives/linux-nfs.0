From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Mon, 08 May 2006 13:20:44 -0400
Message-ID: <445F7DEC.9080805@redhat.com>
References: <444EC96B.80400@RedHat.com>	 <17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com>	 <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com>	 <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com>	 <445B66E6.7030700@redhat.com> <445CB41A.9040400@RedHat.com>	 <445F50AC.1070306@redhat.com> <1147108195.8603.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1147108195.8603.2.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>>
>>I believe that the "key" to the cache entry should be the entire user
>>identification that the NFS server sees and uses when calculating access
>>rights.  Using the uid as part of a hash key is okay and probably a good
>>idea, but I don't think that the uid is sufficient to completely identify
>>a specific cache entry.
>>
>>Given this, then I suspect that the current access cache is broken...
>>    
>>
>
>No it is not: it uses the full RPC cred as the index.
>

Cool!

       ps
