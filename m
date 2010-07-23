Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:42940 "EHLO lists.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab0GWBD7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 21:03:59 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19528.60019.28495.655512@samba.org>
Date: Fri, 23 Jul 2010 11:03:47 +1000
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeremy Allison <jra@samba.org>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Jan Engelhardt <jengelh@medozas.de>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
	file stats available [ver #6]
In-Reply-To: <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
References: <alpine.LSU.2.01.1007221228260.6115@obet.zrqbmnf.qr>
	<20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
	<20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
	<30448.1279800887@redhat.com>
	<E1Obuiy-00C9jr-Al@intern.SerNet.DE>
	<AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
	<E1Obxpd-00CRIo-SF@intern.SerNet.DE>
	<AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
	<20100722162712.GB10352@jeremy-laptop>
	<AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
Reply-To: tridge@samba.org
From: tridge@samba.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

 > My point is that we have three timestamps, and
 > windows wants three timestamps (somebody claims that NTFS has four
 > timestamps, but the Windows file time access functions certainly only
 > shows three times, so any potential extra on-disk times have no
 > relevance because they are invisible to pretty much everybody).

Not quite. The underlying structure available to Windows programmers
is this one:

typedef struct _FILE_BASIC_INFORMATION {
  LARGE_INTEGER CreationTime;
  LARGE_INTEGER LastAccessTime;
  LARGE_INTEGER LastWriteTime;
  LARGE_INTEGER ChangeTime;
  ULONG         FileAttributes;
} FILE_BASIC_INFORMATION, *PFILE_BASIC_INFORMATION;

See http://msdn.microsoft.com/en-us/library/ff545762%28v=VS.85%29.aspx

These are the definitions:

CreationTime
    Specifies the time that the file was created. 
LastAccessTime
    Specifies the time that the file was last accessed. 
LastWriteTime
    Specifies the time that the file was last written to. 
ChangeTime
    Specifies the last time the file was changed. 

You are right that the more commonly used APIs (such as
GetFileInformationByHandle()) omit the ChangeTime field in the return
value. The ChangeTime is also not visible via the normal Windows GUI
or command line tools.

But there are APIs that are used by quite a few programs that do get
all 4 timestamps. For example, GetFileInformationByHandleEx() returns
all 4 fields. I include an example program that uses that API to show
all the timestamps below.

and yes, we think that real applications (such as Excel), look at
these values separately.

The other big difference from POSIX timestamps is that the
CreationTime is settable on Windows, and some of the windows UI
behaviour relies on this.

Cheers, Tridge

PS: Sorry for coming into this discussion so late


/* 
   show all 4 file times
   tridge@samba.org, July 2010
*/

#define _WIN32_WINNT 0x0600

#include <stdio.h>
#include <stdlib.h>
#include "windows.h"
#include "winbase.h"


static void FileTime(const char *fname)
{
	HANDLE h;
	FILE_BASIC_INFO info;
	BOOL ret;

        h = CreateFile(
                fname, GENERIC_READ, 
                FILE_SHARE_READ,
                NULL,           
                OPEN_EXISTING,  
                0,
                NULL
        );
	if (h == INVALID_HANDLE_VALUE) {
		printf("Unable to open %s\n", fname);
		exit(1);
	}

	ret = GetFileInformationByHandleEx(h, FileBasicInfo, &info, sizeof(info));

	if (!ret) {
		printf("Unable to get file information\n");
		exit(1);
	}

	printf("CreationTime:   %llu\n", (unsigned long long)info.CreationTime.QuadPart);
	printf("LastAccessTime: %llu\n", (unsigned long long)info.LastAccessTime.QuadPart);
	printf("LastWriteTime:  %llu\n", (unsigned long long)info.LastWriteTime.QuadPart);
	printf("ChangeTime:     %llu\n", (unsigned long long)info.ChangeTime.QuadPart);

	CloseHandle(h);
}

int main(int argc, char* argv[])
{
	if (argc < 2) {
		printf("Usage: filetime FILENAME\n");
		exit(1);
	}

	FileTime(argv[1]);
	return 0;
}
