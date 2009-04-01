From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/6] nfs-utils: store the address given in the upcall for
	later use
Date: Wed, 1 Apr 2009 13:14:46 -0400
Message-ID: <D783F12F-0D45-486C-A5FA-7216AF5A90D5@oracle.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-3-git-send-email-jlayton@redhat.com>
	<8A187B5F-2B84-498E-9F05-43465BE8FECB@oracle.com>
	<20090401130600.7cbe1be1@barsoom.rdu.redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090401130600.7cbe1be1@barsoom.rdu.redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 1, 2009, at 1:06 PM, Jeff Layton wrote:
> On Wed, 1 Apr 2009 12:58:09 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>> +	if (!addrstr_to_sockaddr(addr, address, port))
>>> 		goto fail;
>>> -	}
>>> -	if (!(*servername = calloc(strlen(ent->h_name) + 1, 1)))
>>> +
>>> +	*servername = sockaddr_to_hostname(addr, address);
>>> +	if (*servername == NULL)
>>> 		goto fail;
>>> -	memcpy(*servername, ent->h_name, strlen(ent->h_name));
>>> -	snprintf(buf, INFOBUFLEN, "%s@%s", service, ent->h_name);
>>> +
>>> +	snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
>>
>> You should check the return code here.  It should be not greater than
>> INFOBUFLEN.
>>
>
> Do we really need to do this? Doesn't using snprintf guarantee that
> it won't be?

The point of the check is to see if a buffer overflow _would_ have  
occurred.  If the string was larger than the buffer, then we know  
either the service or *servername is somehow invalid (like not  
terminated with '\0').  Or, perhaps some error occurred inside snprintf.

Either way, you should check the return code here.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
