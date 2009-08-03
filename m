From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 3/8] NFS Mount Configuration File (Vers 2)
Date: Mon, 03 Aug 2009 11:48:56 -0400
Message-ID: <4A7706E8.7060106@RedHat.com>
References: <4A76F8E6.2010607@RedHat.com> <4A76F9E9.5020604@RedHat.com>
	<20090803152409.GB28838@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090803152409.GB28838@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/03/2009 11:24 AM, J. Bruce Fields wrote:
> On Mon, Aug 03, 2009 at 10:53:29AM -0400, Steve Dickson wrote:
>> commit 528e270be6bb3e4a072cbbb7f3a8b378b64b7fba
>> Author: Steve Dickson <steved@redhat.com>
>> Date:   Mon Mar 9 13:57:10 2009 -0400
>>
>>     Store values in lower case. This makes it easier to do string
>>     comparisons when reading lists from the configuration file.
> 
> Just curious--which parts of the configuration file (section headers,
> keys, values--looks like maybe all 3?) are you making case-insensitive,
> and why do they need to be?
Yes all three of them... 
> 
> E.g. the idmapd configuration file contains paths and user/group names,
> and both those still need to be case sensitive.
hmm... good point... I would suspect this might be the case for
all users of these routines since pathnames and user/group names
are always case-sensitive.... 

I would guess both the section and keys can be case-insensitive
but the key probably say case-sensitive...

steved.
