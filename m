From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/5] nfs-utils: store the address given in the upcall for
	later use
Date: Mon, 6 Apr 2009 12:39:02 -0400
Message-ID: <30EEEB35-4263-4CE1-8066-2AF94B5D30D1@oracle.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-3-git-send-email-jlayton@redhat.com>
	<A1DB402A-E0EA-49BC-99F0-D086FF04B063@oracle.com>
	<20090406123143.1d0671e6@tleilax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090406123143.1d0671e6@tleilax.poochiereds.net>
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

On Apr 6, 2009, at 12:31 PM, Jeff Layton wrote:
> On Mon, 6 Apr 2009 11:35:50 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>> On Apr 5, 2009, at 9:43 AM, Jeff Layton wrote:
>>> + */
>>> +static int
>>> +addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const
>>> int port)
>>> +{
>>> +	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
>>> +
>>> +	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
>>> +		s4->sin_family = AF_INET;
>>> +		s4->sin_port = htons(port);
>>> +	} else {
>>> +		printerr(0, "ERROR: unable to convert %s to address\n", addr);
>>> +		return 0;
>>> +	}
>>
>> I've handled these with a switch statement, as you do later in
>> populate_port().  It's merely a question about consistent coding
>> style, but any reason not to take that approach here?
>>
>
> Yes. switch statements are really only suitable when you have a simple
> value to compare against. We're not comparing the address family here
> because it's not yet known. We have to try and convert this opaque
> string to an address first.
>
> In the last patch, I add an "else if" where we try to convert it to an
> ipv6 addr, but we can't really do "try this and if that fails then try
> this" in the context of a switch.

Just avoid doing the "break;" if inet_ntop(AF_INET6) fails.  Just a  
suggestion.  Some might feel that's too clever.

> In other places I try to use switches where it's suitable...

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
