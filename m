From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Patch 3/8] NFS Mount Configuration File (Vers 2)
Date: Wed, 05 Aug 2009 16:03:54 -0400
Message-ID: <4A79E5AA.6080102@RedHat.com>
References: <4A76F8E6.2010607@RedHat.com> <4A76F9E9.5020604@RedHat.com>
	<20090803152409.GB28838@fieldses.org> <4A7706E8.7060106@RedHat.com>
	<20090803155658.GF28838@fieldses.org> <4A79DA03.20703@RedHat.com>
	<20090805192919.GI9944@fieldses.org>
	<20090805193316.GJ9944@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090805193316.GJ9944@fieldses.org>
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



On 08/05/2009 03:33 PM, J. Bruce Fields wrote:
> On Wed, Aug 05, 2009 at 03:29:19PM -0400, J. Bruce Fields wrote:
>> On Wed, Aug 05, 2009 at 03:14:11PM -0400, Steve Dickson wrote:
>>> After thinking about this.. I've convinced myself that the internal
>>> parsing routines should make the Section names case-insensitive 
>>> but the rest of the data (i.e the tag, value) should be returned as is
>>> and let the callers deal with the case... 
>>>
>>> The reason being everything hangs off Section names. So making those
>>> easier to find I think is a good thing and hopefully it will make
>>> managing config files a bit less error prone.... 
>> That's probably not what I would do, but I could live with that, as long
>> as we're preserving the case of paths and user/group names.
>>
>> By the way, it looks like the git code to handle their extended section
>> names (the [key "string"] thing) is in git's
>> config.c:get_extended_base_var(), if that's a useful example.
> 
> (And, by the way, they agree with you on case-sensitivity: from the
> git-config man page:
Every dog has his day!! 8-) 

steved.
