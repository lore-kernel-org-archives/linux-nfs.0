From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 	(XATTR)
Date: Wed, 17 Mar 2010 14:23:36 -0700
Message-ID: <4BA14858.2060701@schaufler-ca.com>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>	 <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org>	 <20100309035932.GA14237@cynthia.pants.nu>	 <4B95E167.40306@schaufler-ca.com> <7e0fb38c1003171313i3bb81da3xda3a1d28f822d019@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Brad Boyer <flar@allandria.com>, James Morris <jmorris@namei.org>,
	linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <7e0fb38c1003171313i3bb81da3xda3a1d28f822d019@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric Paris wrote:
> On Tue, Mar 9, 2010 at 1:49 AM, Casey Schaufler <casey@schaufler-ca.com> wrote:
>
>   
>> Another is to NFS mount the filesystem back on to the server,
>> in which case James' scheme works just dandy. It's a trick that
>> I've used more than once in the Unix world for this exact purpose.
>> Of course you have to arrange your mount points in advance with
>> malice aforethought, but that's likely something you're used to
>> by now.
>>     
>
> Is this safe with NFS on Linux?  I know in the past (RHEL5) mounting
> NFS over loopback can cause deadlocks under even slight memory
> pressure.  I complained about it and was told 'don't do that, just
> bind mount.'
>
>   

Sigh. Dedicate your NFS server as an NFS server and never let
anyone long onto it then. The point is well past made, I think.


> -Eric
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

