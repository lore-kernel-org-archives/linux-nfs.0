From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 08 Jan 2008 21:51:11 -0500
Message-ID: <4784369F.9060701@redhat.com>
References: <4781BB0D.90706@redhat.com>
	<18307.1933.159410.677626@notabene.brown>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: cluster-devel@redhat.com, NFS list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <18307.1933.159410.677626@notabene.brown>
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

Neil Brown wrote:

>On Monday January 7, wcheng@redhat.com wrote:
>  
>
>>We've implemented two new NFSD procfs files:
>>
>>o /proc/fs/nfsd/unlock_ip
>>o /proc/fs/nfsd/unlock_filesystem
>>
>>They are intended to allow admin or user mode script to release NLM 
>>locks based on either a path name or a server in-bound ip address (ipv4 
>>for now)
>>as;
>>
>>shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
>>shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem
>>    
>>
>
>I'm happy with this interface and the code looks credible, so 
>  Acked-by: NeilBrown <neilb@suse.de>
>
>however......
>  
>
[snip]

Thank .. all points taken .. patch will be re-submitted tomorrow (my 
time zone, North Carolina, US) ..

-- Wendy
