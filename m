From: Bob Kryger <bobk@panix.com>
Subject: Re: [NFS] nfs write problems
Date: Thu, 04 Oct 2007 16:12:20 -0400
Message-ID: <47054924.2040003@panix.com>
References: <4702A279.3080001@panix.com>
	<1191370059.6707.38.camel@heimdal.trondhjem.org>
	<47036D3F.8070904@panix.com> <20071003133118.GP21675@fieldses.org>
Reply-To: For users of Fedora <fedora-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <fedora-list-bounces@redhat.com>
In-Reply-To: <20071003133118.GP21675@fieldses.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Sender: fedora-list-bounces@redhat.com
Errors-To: fedora-list-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

Interesting development that changes the suspect component.

On the suggestion of a colleague I setup samba and mounted the same 
location via CIFS.
I am getting the same results the files are corrupted if they are 
written via samba or NFS.

Now, I'm really confused. I guess I'll try swapping out the SCSI HBA.

Thanks
Bob

J. Bruce Fields wrote:
> On Wed, Oct 03, 2007 at 06:21:51AM -0400, Bob Kryger wrote:
>   
>> Trond Myklebust wrote:
>>     
>>> Feel free to describe your test in a bit more detail. Without more
>>> information, we obviously can't rule out the existence of an NFS bug,
>>>   
>>>       
>> I was trying to be thorough, I hope I succeeded.
>>     
>
> The dd test sounded simple enough, but if you could include a transcript
> of the commands you ran (together with the C code of any test programs)
> just to be sure, that might help.
>
> --b.
>
>
>   

-- 
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: https://www.redhat.com/mailman/listinfo/fedora-list
