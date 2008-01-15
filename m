From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 15 Jan 2008 11:14:54 -0500
Message-ID: <478CDBFE.4080905@redhat.com>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
	<20080114230742.GA16975@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Christoph Hellwig <hch@infradead.org>, NeilBrown <neilb@suse.de>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <20080114230742.GA16975@fieldses.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
>>  
>> +static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
>> +{
>> +	__be32 server_ip;
>> +	char *fo_path;
>> +	char *mesg;
>> +
>> +	/* sanity check */
>> +	if (size <= 0)
>> +		return -EINVAL;
>>     
>
> Not only is size never negative, it's actually an unsigned type here, so
> this is a no-op.
>   

Based on comment from Neil, let's keep this ?

>   
>> +
>> +	if (buf[size-1] == '\n')
>> +		buf[size-1] = 0;
>>     
>
> The other write methods in this file actually just do
>
> 	if (buf[size-1] != '\n')
> 		return -EINVAL;
>
> I don't know why.  But absent some reason, I'd rather these two new
> files behaved the same as existing ones.
>   
ok, fixed.

>   
>> +
>> +	fo_path = mesg = buf;
>> +	if (qword_get(&mesg, fo_path, size) < 0)
>> +		return -EINVAL;
>>     
>
> "mesg" is unneeded here, right?  You can just do:
>
> 	fo_path = buf;
> 	if (qword_get(&buf, buf, size) < 0)
>   

A left-over from previous patch where the command parsing is done by a 
common routine. Will fix this for now.
>   
>> +
>> +	server_ip = in_aton(fo_path);
>>     
>
> It'd be nice if we could sanity-check this.  (Is there code already in
> the kernel someplace to do this?)
>   

The argument here is that if this is a bogus address, the search (of nlm 
files list) will fail (not found) later anyway. Failover is normally 
time critical. Quicker we finish, less issues will be seen. The sanity 
check here can be skipped (imo).
> And, this isn't your problem for now, but eventually I guess this will
> have to accept an ivp6 address as well?
>   

yeah .. Thinking about this right now.. May be borrowing the code from 
ip_map_parse() as Neil pointed out in another mail ?
>   
>> +static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
>> +{
>> +	struct nameidata nd;
>> +	char *fo_path;
>> +	char *mesg;
>> +	int error;
>> +
>> +	/* sanity check */
>> +	if (size <= 0)
>> +		return -EINVAL;
>> +
>> +	if (buf[size-1] == '\n')
>> +		buf[size-1] = 0;
>> +
>> +	fo_path = mesg = buf;
>> +	if (qword_get(&mesg, fo_path, size) < 0)
>> +		return -EINVAL;
>>     
>
> Same comments as above.
>   
ok, fixed.

...
[snip]
>>  /*
>>   * Inspect a single file
>>   */
>> @@ -230,27 +241,37 @@ nlm_file_inuse(struct nlm_file *file)
>>   * Loop over all files in the file table.
>>   */
>>  static int
>> -nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
>> +nlm_traverse_files(void *data, nlm_host_match_fn_t match,
>> +		int (*failover)(void *data, struct nlm_file *file))
>>  {
>>  	struct hlist_node *pos, *next;
>>  	struct nlm_file	*file;
>> -	int i, ret = 0;
>> +	int i, ret = 0, inspect_file;
>>  
>>  	mutex_lock(&nlm_file_mutex);
>>  	for (i = 0; i < FILE_NRHASH; i++) {
>>  		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
>>  			file->f_count++;
>>  			mutex_unlock(&nlm_file_mutex);
>> +			inspect_file = 1;
>>  
>>  			/* Traverse locks, blocks and shares of this file
>>  			 * and update file->f_locks count */
>> -			if (nlm_inspect_file(host, file, match))
>> +
>> +			if (unlikely(failover)) {
>> +				if (!failover(data, file)) {
>> +					inspect_file = 0;
>> +					file->f_locks = nlm_file_inuse(file);
>> +				}
>> +			}
>> +
>> +			if (inspect_file && nlm_inspect_file(data, file, match))
>>  				ret = 1;
>>     
>
> This seems quite complicated!  I don't have an alternative suggestion,
> though.
>   
I hear you .... we also need to look into other (vfs) layer locking 
functions and do an overall cleanup eventuall. It is not related to the 
failover function though.

Will post the revised patch after a light testing soon ...

-- Wendy
