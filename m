From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 03/35] pnfsd, pnfs: protocol level pnfs constants
Date: Tue, 08 Dec 2009 16:31:45 +0200
Message-ID: <4B1E6351.90500@panasas.com>
References: <4B1CCA52.8020900@panasas.com> <1260178224-14745-1-git-send-email-bhalevy@panasas.com> <20091207192533.GA32454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Marc Eshel <eshel@almaden.ibm.com>,
	Fred Isaman <iisaman@citi.umich.edu>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091207192533.GA32454@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec. 07, 2009, 21:25 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Mon, Dec 07, 2009 at 11:30:24AM +0200, Benny Halevy wrote:

<snip>

>> +
>> +/* FIXME: should recall and return types be combined? */
> 
> Is there any reason not to?

Not really.  In fact on the client side we use almost exclusively
the RECALL_* constants, whether they come from the layoutrecall path
or from a voluntary return path.

Benny

> 
> --b.
> 
>> +enum pnfs_layoutrecall_type {
>> +	RECALL_FILE = 1,
>> +	RECALL_FSID = 2,
>> +	RECALL_ALL  = 3
>> +};
>> +
>> +enum pnfs_layoutreturn_type {
>> +	RETURN_FILE = 1,
>> +	RETURN_FSID = 2,
>> +	RETURN_ALL  = 3
>> +};
>> +
