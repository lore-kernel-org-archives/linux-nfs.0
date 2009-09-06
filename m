From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: mount.nfs oops [was: mmotm 2009-09-03-16-35 uploaded]
Date: Sun, 06 Sep 2009 18:11:03 +0200
Message-ID: <4AA3DF17.2000401@gmail.com>
References: <200909032340.n83Ne6E6004708@imap1.linux-foundation.org>	 <4AA17E74.8060100@gmail.com>	 <1252102337.5274.4.camel@heimdal.trondhjem.org>	 <4AA19420.5060503@gmail.com> <1252104797.5274.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758030AbZIFQLH@vger.kernel.org>
In-Reply-To: <1252104797.5274.19.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/05/2009 12:53 AM, Trond Myklebust wrote:
> On Sat, 2009-09-05 at 00:26 +0200, Jiri Slaby wrote:
>> On 09/05/2009 12:12 AM, Trond Myklebust wrote:
>>> Also, were you doing anything special at the time (for instance removing
>>> a module)?
>>
>> Not at all. I just did
>> # mount /work
>> # grep work /etc/fstab
>> XXX.YYY.ZZZ:/work     /work           nfs     defaults,intr   0 0
>>
> Hmm... Is it fully reproducible? I'm running the same NFS client code
> (although not the full linux-mm) on several different client platforms
> without seeing any issues.

I saw this only twice on the same bootup. I can't reproduce on demand,
sorry.
